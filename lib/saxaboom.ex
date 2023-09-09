defmodule Saxaboom do
  @moduledoc """
  Documentation for `Saxaboom`.
  """

alias Saxaboom.Element
alias Saxaboom.Stack

def parse(xml, feed) when is_binary(xml) do
  document_element = %Element{name: "document"}
  element_stack = %Stack{} |> Stack.push(document_element)
  handler_stack = %Stack{} |> Stack.push({-1, struct(feed)})

  {:ok, %{ handler_stack: handler_stack }, _} =
    :erlsom.parse_sax(
      xml,
      %{
        element_stack: element_stack,
        handler_stack: handler_stack,
      },
      &handle_event/2
    )

  {{_, parsed}, _} = Stack.pop(handler_stack)
  {:ok, parsed}
end

def handle_event(
      {:startElement, _uri, local_name, _prefix, attributes},
      %{element_stack: element_stack, handler_stack: handler_stack} = state
    ) do
  local_name = to_string(local_name)
  attributes = normalize_attributes(attributes)

  current_element = %Element{name: local_name, attributes: attributes}
  {_, current_handler} = Stack.top(handler_stack)
  depth = Stack.size(element_stack)

  handler_definition = current_handler.__struct__.__element_definition__(current_handler, current_element)
  handler_stack = if handler_definition && handler_definition.into do
    Stack.push(handler_stack, {depth, struct(handler_definition.into)})
  else
    handler_stack
  end

  element_stack = Stack.push(element_stack, current_element)
  %{state | element_stack: element_stack, handler_stack: handler_stack}
end

def handle_event(
      {:endElement, _uri, _local_name, _prefix},
      %{element_stack: element_stack, handler_stack: handler_stack} = state
    ) do
  {current_element, element_stack} = Stack.pop(element_stack)
  {handler_info, handler_stack} = Stack.pop(handler_stack)
  {introduced_depth, current_handler} = handler_info
  depth = Stack.size(element_stack)

  current_handler = current_handler.__struct__.__cast_element__(current_handler, current_element)
  handler_stack = Stack.push(handler_stack, {introduced_depth, current_handler})

  handler_stack = if introduced_depth == depth do
    {{_, parsed_handler}, handler_stack} = Stack.pop(handler_stack)
    {parent_depth, parent_handler} = Stack.top(handler_stack)
    parent_handler = parent_handler.__struct__.__cast_nested__(parent_handler, current_element, parsed_handler)
    Stack.swap(handler_stack, {parent_depth, parent_handler})
  else
    handler_stack
  end

  %{state | element_stack: element_stack, handler_stack: handler_stack}
end

def handle_event({:characters, characters}, %{element_stack: element_stack} = state) do
  {current, element_stack} = Stack.pop(element_stack)
  current = %Element{current | text: to_string(characters)}
  %{state | element_stack: Stack.push(element_stack, current)}
end

def handle_event(_event, state), do: state

def normalize_attributes(attributes) do
  attributes
    |> Enum.map(fn {_, attr_name, _, _, attr_value} ->
      {to_string(attr_name), to_string(attr_value)}
    end)
    |> Enum.into(%{})
end
end
