if Code.ensure_loaded?(:erlsom) do
  defmodule Saxaboom.Adapters.Erlsom do
    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.Adapters.Adapter
    alias Saxaboom.Element
    alias Saxaboom.Stack
    alias Saxaboom.State

    @impl true
    def parse(xml, into, adapter_options) when is_binary(xml) do
      {:ok, %{machine_state: machine_state}, _} =
        :erlsom.parse_sax(
          xml,
          Adapter.initialize_state(into),
          &handle_event/2,
          adapter_options
        )

      parsed = State.finish(machine_state)
      {:ok, parsed}
    end

    @impl true
    def parse(xml, into, adapter_options) do
      {:ok, %{machine_state: machine_state}, _} =
        :erlsom.parse_sax(
          "",
          Adapter.initialize_state(into),
          &handle_event/2,
          adapter_options ++
            [
              {
                :continuation_function,
                fn tail, stream ->
                  {lines, stream} = StreamSplit.take_and_drop(stream, 1)
                  {tail <> Enum.join(lines, ""), stream}
                end,
                xml
              }
            ]
        )

      parsed = State.finish(machine_state)
      {:ok, parsed}
    end

    def handle_event(
          {:startElement, _uri, local_name, prefix, attributes},
          %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
        ) do
      name = Enum.join([prefix, local_name] |> Enum.reject(fn val -> val == ~c"" end), ":")
      attributes = normalize_attributes(attributes)
      current_element = %Element{name: name, attributes: attributes}

      :ok = State.start_element(machine_state, current_element, depth)

      element_stack = Stack.push(element_stack, current_element)
      %{state | element_stack: element_stack, depth: depth + 1}
    end

    def handle_event(
          {:endElement, _uri, _local_name, _prefix},
          %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
        ) do
      {current_element, element_stack} = Stack.pop(element_stack)
      depth = depth - 1

      :ok = State.end_element(machine_state, current_element, depth)

      %{state | element_stack: element_stack, depth: depth}
    end

    def handle_event(
          {:characters, characters},
          %{element_stack: element_stack} = state
        ) do
      {current, element_stack} = Stack.pop(element_stack)
      current = %Element{current | text: to_string(characters)}
      %{state | element_stack: Stack.push(element_stack, current)}
    end

    def handle_event(_event, state), do: state

    def normalize_attributes(attributes) do
      attributes
      |> Enum.map(fn {_kind, name, prefix, _, value} ->
        {Enum.join([prefix, name] |> Enum.reject(fn val -> val == ~c"" end), ":"),
         to_string(value)}
      end)
      |> Enum.into(%{})
    end
  end
end
