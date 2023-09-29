if Code.ensure_loaded?(:erlsom) do
  defmodule Saxaboom.Adapters.Erlsom do
    @moduledoc false

    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.State

    @impl true
    def parse(xml, into, parser_options) when is_binary(xml) do
      {:ok, machine_state_pid} = State.start_link(into)

      case :erlsom.parse_sax(
             xml,
             %{machine_state_pid: machine_state_pid},
             &handle_event/2,
             parser_options
           ) do
        {:ok, %{machine_state_pid: machine_state_pid}, _} ->
          parsed = State.finish(machine_state_pid)
          {:ok, parsed}

        err ->
          err
      end
    catch
      err -> err
    end

    @impl true
    def parse(xml, into, parser_options) do
      {:ok, machine_state_pid} = State.start_link(into)

      {:ok, %{machine_state_pid: machine_state_pid}, _} =
        :erlsom.parse_sax(
          "",
          %{machine_state_pid: machine_state_pid},
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

      parsed = State.finish(machine_state_pid)
      {:ok, parsed}
    end

    def handle_event(
          {:startElement, _uri, local_name, prefix, attributes},
          %{machine_state_pid: machine_state_pid} = state
        ) do
      name = normalize_name(prefix, local_name)
      attributes = normalize_attributes(attributes)

      :ok = State.start_element(machine_state_pid, name, attributes)

      state
    end

    def handle_event(
          {:endElement, _uri, local_name, prefix},
          %{machine_state_pid: machine_state_pid} = state
        ) do
      name = normalize_name(prefix, local_name)
      :ok = State.end_element(machine_state_pid, name)

      state
    end

    def handle_event(
          {:characters, characters},
          %{machine_state_pid: machine_state_pid} = state
        ) do
      :ok = State.characters(machine_state_pid, to_string(characters))
      state
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
