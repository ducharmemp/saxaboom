defmodule Saxaboom.Adapters.Xmerl do
  @behaviour Saxaboom.Adapters.AdapterBehaviour

  alias Saxaboom.Element
  alias Saxaboom.Stack
  alias Saxaboom.State

  @impl true
  def parse(xml, into) do
    document_element = %Element{name: "document"}
    element_stack = [] |> Stack.push(document_element)
    {:ok, machine_state} = State.start_link(struct(into))

    {:ok, _, _} =
      :xmerl_sax_parser.stream(
        xml,
        [
          {:event_fun, &handle_event/3},
          {:event_state, %{element_stack: element_stack, machine_state: machine_state, depth: 0}}
        ]
      )

    parsed = State.finish(machine_state)
    {:ok, parsed}
  end

  def handle_event(
        {:startElement, _uri, local_name, _qualified_name, attributes},
        _location,
        %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
      ) do
    attributes = normalize_attributes(attributes)
    current_element = %Element{name: local_name, attributes: attributes}

    :ok = State.start_element(machine_state, current_element, depth)

    element_stack = Stack.push(element_stack, current_element)
    {:ok, %{state | element_stack: element_stack, depth: depth + 1}}
  end

  def handle_event(
        {:endElement, _uri, _local_name, _qualified_name},
        _location,
        %{element_stack: element_stack, machine_state: machine_state, depth: depth} = state
      ) do
    {current_element, element_stack} = Stack.pop(element_stack)
    depth = depth - 1

    :ok = State.end_element(machine_state, current_element, depth)

    {:ok, %{state | element_stack: element_stack, depth: depth}}
  end

  def handle_event(
        {:characters, characters},
        _location,
        %{element_stack: element_stack} = state
      ) do
    {current, element_stack} = Stack.pop(element_stack)
    current = %Element{current | text: to_string(characters)}
    {:ok, %{state | element_stack: Stack.push(element_stack, current)}}
  end

  def handle_event(_event, _arg, state), do: {:ok, state}

  def normalize_attributes(attributes) do
    attributes
    |> Enum.map(fn {_uri, _prefix, attribute_name, value} -> {attribute_name, value} end)
    |> Enum.into(%{})
  end
end
