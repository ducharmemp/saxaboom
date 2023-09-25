defmodule Saxaboom.Adapters.Adapter do
  @callback parse(xml :: term, into :: term, adapter_options :: term) :: {:ok, parsed :: term}

  alias Saxaboom.Element
  alias Saxaboom.Stack
  alias Saxaboom.State

  def initialize_state(into) do
    document_element = %Element{name: "document"}
    element_stack = [] |> Stack.push(document_element)
    {:ok, machine_state} = State.start_link(into)

    %{element_stack: element_stack, machine_state: machine_state, depth: 0}
  end
end
