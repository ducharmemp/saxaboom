if Code.ensure_loaded?(:erlsom) do
  defmodule Saxaboom.Adapters.Erlsom do
    @moduledoc false

    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.State

    @impl true
    def parse(xml, into, parser_options) when is_binary(xml) do
      state = State.start_link(into)

      case :erlsom.parse_sax(
             xml,
             state,
             &handle_event/2,
             parser_options
           ) do
        {:ok, state, _} ->
          parsed = State.finish(state)
          {:ok, parsed}

        err ->
          err
      end
    catch
      err -> err
    end

    @impl true
    def parse(xml, into, parser_options) do
      state = State.start_link(into)

      {:ok, state, _} =
        :erlsom.parse_sax(
          "",
          state,
          &handle_event/2,
          parser_options ++
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

      parsed = State.finish(state)
      {:ok, parsed}
    end

    def handle_event(
          {:startElement, _uri, local_name, prefix, attributes},
          state = state
        ) do
      name = normalize_name(prefix, local_name)
      attributes = normalize_attributes(attributes)

      State.start_element(state, name, attributes)
    end

    def handle_event(
          {:endElement, _uri, local_name, prefix},
          state = state
        ) do
      name = normalize_name(prefix, local_name)
      State.end_element(state, name)
    end

    def handle_event(
          {:characters, characters},
          state = state
        ) do
      State.characters(state, to_string(characters))
    end

    def handle_event(_event, state), do: state

    defp normalize_name(prefix, local_name),
      do: Enum.join([prefix, local_name] |> Enum.reject(fn val -> val == ~c"" end), ":")

    defp normalize_attributes(attributes) do
      attributes
      |> Enum.map(fn {_kind, name, prefix, _, value} ->
        {Enum.join([prefix, name] |> Enum.reject(fn val -> val == ~c"" end), ":"),
         to_string(value)}
      end)
      |> Enum.into(%{})
    end
  end
end
