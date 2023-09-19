if Code.ensure_loaded?(Saxy) do
  defmodule Saxaboom.Adapters.Saxy do
    @moduledoc """
    Documentation for `Saxaboom.Adapters.Sax`.
    """
    @behaviour Saxy.Handler
    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.Adapters.Adapter
    alias Saxaboom.Element
    alias Saxaboom.Stack
    alias Saxaboom.State

    def parse(xml, into) when is_binary(xml) do
      {:ok, %{machine_state: machine_state}} =
        Saxy.parse_string(xml, __MODULE__, Adapter.initialize_state(into))

      parsed = State.finish(machine_state)
      {:ok, parsed}
    end

    def parse(xml, into) do
      {:ok, %{machine_state: machine_state}} =
        Saxy.parse_stream(xml, __MODULE__, Adapter.initialize_state(into))

      parsed = State.finish(machine_state)
      {:ok, parsed}
    end

    def handle_event(
          :start_element,
          {local_name, attributes},
          %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
        ) do
      attributes = normalize_attributes(attributes)
      current_element = %Element{name: local_name, attributes: attributes}

      :ok = State.start_element(machine_state, current_element, depth)

      element_stack = Stack.push(element_stack, current_element)
      {:ok, %{state | element_stack: element_stack, depth: depth + 1}}
    end

    def handle_event(
          :end_element,
          _local_name,
          %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
        ) do
      {current_element, element_stack} = Stack.pop(element_stack)
      depth = depth - 1

      :ok = State.end_element(machine_state, current_element, depth)

      {:ok, %{state | element_stack: element_stack, depth: depth}}
    end

    def handle_event(:characters, characters, %{element_stack: element_stack} = state) do
      {current, element_stack} = Stack.pop(element_stack)
      current = %Element{current | text: to_string(characters)}
      {:ok, %{state | element_stack: Stack.push(element_stack, current)}}
    end

    def handle_event(_event, _arg, state), do: {:ok, state}

    def normalize_attributes(attributes) do
      attributes
      |> Enum.into(%{})
    end
  end
end
