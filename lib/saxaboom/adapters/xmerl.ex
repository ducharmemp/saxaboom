defmodule Saxaboom.Adapters.Xmerl do
  @moduledoc false

  @behaviour Saxaboom.Adapters.Adapter

  alias Saxaboom.State

  @impl true
  def parse(xml, into, parser_options) when is_binary(xml) do
    {:ok, machine_state_pid} = State.start_link(into)

    case :xmerl_sax_parser.stream(
           xml,
           parser_options ++
             [
               event_fun: &handle_event/3,
               event_state: %{machine_state_pid: machine_state_pid}
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
    {:ok, machine_state_pid} = State.start_link(into)

    {:ok, %{machine_state_pid: machine_state_pid}, _} =
      :xmerl_sax_parser.stream(
        "",
        parser_options ++
          [
            event_fun: &handle_event/3,
            event_state: %{machine_state_pid: machine_state_pid},
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
        %{machine_state_pid: machine_state_pid} = state
      ) do
    name = normalize_name(prefix, name)
    attributes = normalize_attributes(attributes)

    :ok = State.start_element(machine_state_pid, name, attributes)
    state
  end

  def handle_event(
        {:endElement, _uri, _local_name, {prefix, name}},
        _location,
        %{machine_state_pid: machine_state_pid} = state
      ) do
    name = normalize_name(prefix, name)
    :ok = State.end_element(machine_state_pid, name)

    state
  end

  def handle_event(
        {:characters, characters},
        _location,
        %{machine_state_pid: machine_state_pid} = state
      ) do
    :ok = State.characters(machine_state_pid, to_string(characters))
    state
  end

  def handle_event(_event, _arg, state), do: state

  defp normalize_name(prefix, local_name),
    do: Enum.join([prefix, local_name] |> Enum.reject(fn val -> val == ~c"" end), ":")

  def normalize_attributes(attributes) do
    attributes
    |> Enum.map(fn {_uri, prefix, name, value} ->
      {Enum.join([prefix, name] |> Enum.reject(fn val -> val == ~c"" end), ":"), to_string(value)}
    end)
    |> Enum.into(%{})
  end
end
