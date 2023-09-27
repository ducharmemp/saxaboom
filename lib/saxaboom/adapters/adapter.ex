defmodule Saxaboom.Adapters.Adapter do
  @moduledoc false

  @callback parse(xml :: term, into :: term, parser_options :: term) :: {:ok, parsed :: term}

  alias Saxaboom.Element
  alias Saxaboom.Stack
  alias Saxaboom.State

  def initialize_state(into) do
    document_element = %Element{name: "document"}
    element_stack = [] |> Stack.push(document_element)
    {:ok, machine_state_pid} = State.start_link(into)

    %{element_stack: element_stack, machine_state_pid: machine_state_pid, depth: 0}
  end
end
