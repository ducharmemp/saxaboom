if Code.ensure_loaded?(Saxy) do
  defmodule Saxaboom.Adapters.Saxy do
    @moduledoc false

    @behaviour Saxy.Handler
    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.State

    def parse(xml, into, parser_options) when is_binary(xml) do
      state = State.initialize(into)

      case Saxy.parse_string(
             xml,
             __MODULE__,
             state,
             parser_options
           ) do
        {:ok, state} ->
          parsed = State.finish(state)
          {:ok, parsed}

        err ->
          err
      end
    end

    def parse(xml, into, parser_options) do
      state = State.initialize(into)

      {:ok, state} =
        Saxy.parse_stream(
          xml,
          __MODULE__,
          state,
          parser_options
        )

      parsed = State.finish(state)
      {:ok, parsed}
    end

    def handle_event(
          :start_element,
          {local_name, attributes},
          state
        ) do
      attributes = normalize_attributes(attributes)
      {:ok, State.start_element(state, local_name, attributes)}
    end

    def handle_event(
          :end_element,
          local_name,
          state
        ) do
      {:ok, State.end_element(state, local_name)}
    end

    def handle_event(:characters, characters, state) do
      {:ok, State.characters(state, characters)}
    end

    def handle_event(:cdata, characters, state) do
      {:ok, State.characters(state, characters)}
    end

    def handle_event(_event, _arg, state), do: {:ok, state}

    def normalize_attributes(attributes) do
      attributes
      |> Enum.into(%{})
    end
  end
end
