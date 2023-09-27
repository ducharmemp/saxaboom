if Code.ensure_loaded?(Saxy) do
  defmodule Saxaboom.Adapters.Saxy do
    @moduledoc false

    @behaviour Saxy.Handler
    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.Adapters.Adapter
    alias Saxaboom.Element
    alias Saxaboom.Stack
    alias Saxaboom.State

    def parse(xml, into, parser_options) when is_binary(xml) do
      case Saxy.parse_string(xml, __MODULE__, Adapter.initialize_state(into), parser_options) do
        {:ok, %{machine_state_pid: machine_state_pid}} ->
          parsed = State.finish(machine_state_pid)
          {:ok, parsed}

        err ->
          err
      end
    end

    def parse(xml, into, parser_options) do
      {:ok, %{machine_state_pid: machine_state_pid}} =
        Saxy.parse_stream(xml, __MODULE__, Adapter.initialize_state(into), parser_options)

      parsed = State.finish(machine_state_pid)
      {:ok, parsed}
    end

    def handle_event(
          :start_element,
          {local_name, attributes},
          %{element_stack: element_stack, machine_state_pid: machine_state_pid, depth: depth} =
            state
        ) do
      attributes = normalize_attributes(attributes)
      current_element = %Element{name: local_name, attributes: attributes}

      :ok = State.start_element(machine_state_pid, current_element, depth)

      element_stack = Stack.push(element_stack, current_element)
      {:ok, %{state | element_stack: element_stack, depth: depth + 1}}
    end

    def handle_event(
          :end_element,
          _local_name,
          %{element_stack: element_stack, machine_state_pid: machine_state_pid, depth: depth} =
            state
        ) do
      {current_element, element_stack} = Stack.pop(element_stack)
      depth = depth - 1

      :ok = State.end_element(machine_state_pid, current_element, depth)

      {:ok, %{state | element_stack: element_stack, depth: depth}}
    end

    def handle_event(:characters, characters, %{element_stack: element_stack} = state) do
      {current, element_stack} = Stack.pop(element_stack)
      current = %Element{current | text: to_string(characters)}
      {:ok, %{state | element_stack: Stack.push(element_stack, current)}}
    end

    def handle_event(:cdata, characters, %{element_stack: element_stack} = state) do
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
