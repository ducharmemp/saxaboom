defmodule Saxaboom.State do
  @moduledoc false

  alias Saxaboom.Element
  alias Saxaboom.ElementCollectable
  alias Saxaboom.Utils.Stack

  defstruct [
    :current_handler,
    introduced_depth: -1,
    current_element: %Element{name: "document"},
    handler_stack: [],
    element_stack: []
  ]

  def initialize(initial_handler) do
    %__MODULE__{current_handler: initial_handler}
  end

  def start_element(self, element_name, attributes) do
    self
    |> push_element(%Element{name: element_name, attributes: attributes})
    |> maybe_push_handler()
    |> update_handler()
  end

  def end_element(self, _element_name) do
    self
    |> maybe_pop_handler()
    |> pop_element()
  end

  def characters(
        %{current_handler: current_handler, current_element: current_element} = self,
        characters
      ) do
    current_handler =
      ElementCollectable.cast_characters(current_handler, current_element, characters)

    %{self | current_element: current_element, current_handler: current_handler}
  end

  def finish(%{current_handler: current_handler}) do
    current_handler
  end

  defp push_element(
         %{element_stack: element_stack, current_element: current_element} = state,
         element
       ) do
    %{state | element_stack: Stack.push(element_stack, current_element), current_element: element}
  end

  defp maybe_push_handler(
         %{
           handler_stack: handler_stack,
           current_handler: current_handler,
           introduced_depth: introduced_depth,
           current_element: current_element,
           element_stack: element_stack
         } = state
       ) do
    handler_definition = ElementCollectable.element_definition(current_handler, current_element)

    if handler_definition && handler_definition.into do
      current_depth = length(element_stack)

      %{
        state
        | handler_stack: Stack.push(handler_stack, {introduced_depth, current_handler}),
          current_handler: handler_definition.into,
          introduced_depth: current_depth
      }
    else
      state
    end
  end

  defp update_handler(
         %{current_handler: current_handler, current_element: current_element} = state
       ) do
    %{
      state
      | current_handler: ElementCollectable.cast_attributes(current_handler, current_element)
    }
  end

  defp maybe_pop_handler(
         %{
           handler_stack: handler_stack,
           introduced_depth: introduced_depth,
           current_handler: current_handler,
           current_element: current_element,
           element_stack: element_stack
         } = state
       ) do
    current_depth = length(element_stack)

    if current_depth == introduced_depth do
      {{parent_introduced_depth, parent_handler}, handler_stack} = Stack.pop(handler_stack)

      parent_handler =
        ElementCollectable.cast_nested(parent_handler, current_element, current_handler)

      %{
        state
        | handler_stack: handler_stack,
          current_handler: parent_handler,
          introduced_depth: parent_introduced_depth
      }
    else
      state
    end
  end

  defp pop_element(%{element_stack: element_stack} = state) do
    {current_element, element_stack} = Stack.pop(element_stack)
    %{state | element_stack: element_stack, current_element: current_element}
  end
end
