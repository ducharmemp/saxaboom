defmodule Saxaboom.State do
  @moduledoc false

  use GenServer

  alias Saxaboom.ElementCollectable
  alias Saxaboom.Stack

  def start_link(initial_handler) do
    GenServer.start_link(__MODULE__, initial_handler, name: __MODULE__)
  end

  def start_element(pid, element, depth) do
    GenServer.cast(pid, {:start_element, element, depth})
  end

  def end_element(pid, element, depth) do
    GenServer.cast(pid, {:end_element, element, depth})
  end

  def finish(pid) do
    handler = GenServer.call(pid, {:finish})
    GenServer.stop(pid)
    handler
  end

  @impl true
  def init(initial_handler) do
    {:ok, [{-1, initial_handler}]}
  end

  @impl true
  def handle_cast({:start_element, element, depth}, handler_stack) do
    {_, current_handler} = Stack.top(handler_stack)

    handler_definition = ElementCollectable.element_definition(current_handler, element)

    handler_stack =
      if handler_definition && handler_definition.into do
        Stack.push(handler_stack, {depth, handler_definition.into})
      else
        handler_stack
      end

    {:noreply, handler_stack}
  end

  @impl true
  def handle_cast({:end_element, element, depth}, handler_stack) do
    {handler_info, handler_stack} = Stack.pop(handler_stack)
    {introduced_depth, current_handler} = handler_info

    handler_stack =
      if introduced_depth == depth do
        {parent_depth, parent_handler} = Stack.top(handler_stack)

        current_handler = ElementCollectable.cast_element(current_handler, element)
        parent_handler = ElementCollectable.cast_nested(parent_handler, element, current_handler)
        Stack.swap(handler_stack, {parent_depth, parent_handler})
      else
        current_handler = ElementCollectable.cast_element(current_handler, element)
        Stack.push(handler_stack, {introduced_depth, current_handler})
      end

    {:noreply, handler_stack}
  end

  @impl true
  def handle_call({:finish}, _from, handler_stack) do
    {_, handler} = Stack.top(handler_stack)
    {:reply, handler, []}
  end
end
