defmodule Saxaboom.State do
  @moduledoc false

  use GenServer

  alias Saxaboom.Element
  alias Saxaboom.ElementCollectable
  alias Saxaboom.Stack

  def start_link(initial_handler) do
    GenServer.start_link(__MODULE__, initial_handler, name: __MODULE__)
  end

  def start_element(pid, element_name, attributes) do
    GenServer.cast(pid, {:start_element, element_name, attributes})
  end

  def end_element(pid, element_name) do
    GenServer.cast(pid, {:end_element, element_name})
  end

  def characters(pid, characters) do
    GenServer.cast(pid, {:characters, characters})
  end

  def finish(pid) do
    handler = GenServer.call(pid, {:finish})
    GenServer.stop(pid)
    handler
  end

  @impl true
  def init(initial_handler) do
    {
      :ok,
      %{
        current_handler: initial_handler,
        introduced_depth: -1,
        current_element: %Element{name: "document"},
        handler_stack: [],
        element_stack: []
      }
    }
  end

  @impl true
  def handle_cast({:start_element, element_name, attributes}, state) do
    state =
      state
      |> push_element(%Element{name: element_name, attributes: attributes})
      |> maybe_push_handler()

    {:noreply, state}
  end

  @impl true
  def handle_cast({:end_element, _element_name}, state) do
    state =
      state
      |> update_handler()
      |> maybe_pop_handler()
      |> pop_element()

    {:noreply, state}
  end

  def handle_cast(
        {:characters, characters},
        %{
          current_element: current_element,
          current_handler: current_handler
        } = state
      ) do
    current_element = %{current_element | text: characters}

    current_handler =
      ElementCollectable.cast_characters(current_handler, current_element, characters)

    {:noreply, %{state | current_element: current_element, current_handler: current_handler}}
  end

  @impl true
  def handle_call({:finish}, _from, %{current_handler: current_handler}) do
    {:reply, current_handler, []}
  end

  defp push_element(
         %{element_stack: element_stack, current_element: current_element} = state,
         element
       ) do
    %{state | element_stack: Stack.push(element_stack, current_element), current_element: element}
  end

  defp maybe_push_handler(
         %{
           handler_stack: handler_stack,
           current_handler: current_handler,
           introduced_depth: introduced_depth,
           current_element: current_element,
           element_stack: element_stack
         } = state
       ) do
    handler_definition = ElementCollectable.element_definition(current_handler, current_element)

    if handler_definition && handler_definition.into do
      current_depth = length(element_stack)

      %{
        state
        | handler_stack: Stack.push(handler_stack, {introduced_depth, current_handler}),
          current_handler: handler_definition.into,
          introduced_depth: current_depth
      }
    else
      state
    end
  end

  defp update_handler(
         %{current_handler: current_handler, current_element: current_element} = state
       ) do
    %{state | current_handler: ElementCollectable.cast_element(current_handler, current_element)}
  end

  defp maybe_pop_handler(
         %{
           handler_stack: handler_stack,
           introduced_depth: introduced_depth,
           current_handler: current_handler,
           current_element: current_element,
           element_stack: element_stack
         } = state
       ) do
    current_depth = length(element_stack)

    if current_depth == introduced_depth do
      {{parent_introduced_depth, parent_handler}, handler_stack} = Stack.pop(handler_stack)
      parent_handler =
        ElementCollectable.cast_nested(parent_handler, current_element, current_handler)

      %{
        state
        | handler_stack: handler_stack,
          current_handler: parent_handler,
          introduced_depth: parent_introduced_depth
      }
    else
      state
    end
  end

  defp pop_element(%{element_stack: element_stack} = state) do
    {current_element, element_stack} = Stack.pop(element_stack)
    %{state | element_stack: element_stack, current_element: current_element}
  end
end
