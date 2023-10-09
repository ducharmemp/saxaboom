defmodule Saxaboom.Adapters.Xmerl do
  @moduledoc false

  @behaviour Saxaboom.Adapters.Adapter

  alias Saxaboom.State

  @impl true
  def parse(xml, into, parser_options) when is_binary(xml) do
    state = State.initialize(into)

    case :xmerl_sax_parser.stream(
           xml,
           parser_options ++
             [
               event_fun: &handle_event/3,
               event_state: state
             ]
         ) do
      {:ok, state, _} ->
        parsed = State.finish(state)
        {:ok, parsed}

      err ->
        err
    end
  end

  @impl true
  def parse(xml, into, parser_options) do
    state = State.initialize(into)

    {:ok, state, _} =
      :xmerl_sax_parser.stream(
        "",
        parser_options ++
          [
            event_fun: &handle_event/3,
            event_state: state,
            continuation_state: xml,
            continuation_fun: fn stream ->
              {lines, stream} = StreamSplit.take_and_drop(stream, 1)
              {Enum.join(lines, ""), stream}
            end
          ]
      )

    parsed = State.finish(state)
    {:ok, parsed}
  end

  def handle_event(
        {:startElement, _uri, _local_name, {prefix, name}, attributes},
        _location,
        state
      ) do
    name = normalize_name(prefix, name)
    attributes = normalize_attributes(attributes)

    State.start_element(state, name, attributes)
  end

  def handle_event(
        {:endElement, _uri, _local_name, {prefix, name}},
        _location,
        state
      ) do
    name = normalize_name(prefix, name)
    State.end_element(state, name)
  end

  def handle_event(
        {:characters, characters},
        _location,
        state
      ) do
    State.characters(state, to_string(characters))
  end

  # def handle_event(:startCDATA, _, state), do: state
  # def handle_event(:endCDATA, _, state), do: state
  # def handle_event(:startDocument, _, state), do: state

  # def handle_event(event, arg, state) do
  #   dbg(event)
  #   state
  # end

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
