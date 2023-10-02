defmodule Support.SinkHandler do
  defstruct [:element_definition, :characters, :nested, attributes: %{}]

  defimpl Saxaboom.ElementCollectable do
    def element_definition(%{element_definition: element_definition}, _element) do
      element_definition
    end

    def cast_characters(collectable, _element, characters) do
      %{collectable | characters: characters}
    end

    def cast_attributes(collectable, %{attributes: attributes} = _element) do
      %{collectable | attributes: attributes}
    end

    def cast_nested(collectable, _element, nested) do
      %{collectable | nested: nested}
    end
  end
end
