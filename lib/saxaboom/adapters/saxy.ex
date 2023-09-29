if Code.ensure_loaded?(Saxy) do
  defmodule Saxaboom.Adapters.Saxy do
    @moduledoc false

    @behaviour Saxy.Handler
    @behaviour Saxaboom.Adapters.Adapter

    alias Saxaboom.State

    def parse(xml, into, parser_options) when is_binary(xml) do
      {:ok, machine_state_pid} = State.start_link(into)

      case Saxy.parse_string(
             xml,
             __MODULE__,
             %{machine_state_pid: machine_state_pid},
             parser_options
           ) do
        {:ok, %{machine_state_pid: machine_state_pid}} ->
          parsed = State.finish(machine_state_pid)
          {:ok, parsed}

        err ->
          err
      end
    end

    def parse(xml, into, parser_options) do
      {:ok, machine_state_pid} = State.start_link(into)

      {:ok, %{machine_state_pid: machine_state_pid}} =
        Saxy.parse_stream(
          xml,
          __MODULE__,
          %{machine_state_pid: machine_state_pid},
          parser_options
        )

      parsed = State.finish(machine_state_pid)
      {:ok, parsed}
    end

    def handle_event(
          :start_element,
          {local_name, attributes},
          %{machine_state_pid: machine_state_pid} = state
        ) do
      attributes = normalize_attributes(attributes)

      :ok = State.start_element(machine_state_pid, local_name, attributes)
      {:ok, state}
    end

    def handle_event(
          :end_element,
          local_name,
          %{machine_state_pid: machine_state_pid} = state
        ) do
      :ok = State.end_element(machine_state_pid, local_name)

      {:ok, state}
    end

    def handle_event(:characters, characters, %{machine_state_pid: machine_state_pid} = state) do
      :ok = State.characters(machine_state_pid, characters)
      {:ok, state}
    end

    def handle_event(:cdata, characters, %{machine_state_pid: machine_state_pid} = state) do
      :ok = State.characters(machine_state_pid, characters)
      {:ok, state}
    end

    def handle_event(_event, _arg, state), do: {:ok, state}

    def normalize_attributes(attributes) do
      attributes
      |> Enum.into(%{})
    end
  end
end
