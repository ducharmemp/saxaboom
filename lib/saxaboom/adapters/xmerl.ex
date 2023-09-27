defmodule Saxaboom.Adapters.Xmerl do
  @moduledoc false

  @behaviour Saxaboom.Adapters.Adapter

  alias Saxaboom.Adapters.Adapter
  alias Saxaboom.Element
  alias Saxaboom.Stack
  alias Saxaboom.State

  @impl true
  def parse(xml, into, parser_options) when is_binary(xml) do
    case :xmerl_sax_parser.stream(
           xml,
           parser_options ++
             [
               event_fun: &handle_event/3,
               event_state: Adapter.initialize_state(into)
             ]
         ) do
      {:ok, %{machine_state_pid: machine_state_pid}, _} ->
        parsed = State.finish(machine_state_pid)
        {:ok, parsed}

      err ->
        err
    end
  end

  @impl true
  def parse(xml, into, parser_options) do
    {:ok, %{machine_state_pid: machine_state_pid}, _} =
      :xmerl_sax_parser.stream(
        "",
        parser_options ++
          [
            event_fun: &handle_event/3,
            event_state: Adapter.initialize_state(into),
            continuation_state: xml,
            continuation_fun: fn stream ->
              {lines, stream} = StreamSplit.take_and_drop(stream, 1)
              {Enum.join(lines, ""), stream}
            end
          ]
      )

    parsed = State.finish(machine_state_pid)
    {:ok, parsed}
  end

  def handle_event(
        {:startElement, _uri, _local_name, {prefix, name}, attributes},
        _location,
        %{element_stack: element_stack, machine_state_pid: machine_state_pid, depth: depth} =
          state
      ) do
    name = Enum.join([prefix, name] |> Enum.reject(fn val -> val == ~c"" end), ":")
    attributes = normalize_attributes(attributes)
    current_element = %Element{name: name, attributes: attributes}

    :ok = State.start_element(machine_state_pid, current_element, depth)

    element_stack = Stack.push(element_stack, current_element)
    %{state | element_stack: element_stack, depth: depth + 1}
  end

  def handle_event(
        {:endElement, _uri, _local_name, _qualified_name},
        _location,
        %{element_stack: element_stack, machine_state_pid: machine_state_pid, depth: depth} =
          state
      ) do
    {current_element, element_stack} = Stack.pop(element_stack)
    depth = depth - 1

    :ok = State.end_element(machine_state_pid, current_element, depth)

    %{state | element_stack: element_stack, depth: depth}
  end

  def handle_event(
        {:characters, characters},
        _location,
        %{element_stack: element_stack} = state
      ) do
    {current, element_stack} = Stack.pop(element_stack)
    current = %Element{current | text: to_string(characters)}
    %{state | element_stack: Stack.push(element_stack, current)}
  end

  def handle_event(_event, _arg, state), do: state

  def normalize_attributes(attributes) do
    attributes
    |> Enum.map(fn {_uri, prefix, name, value} ->
      {Enum.join([prefix, name] |> Enum.reject(fn val -> val == ~c"" end), ":"), to_string(value)}
    end)
    |> Enum.into(%{})
  end
end
