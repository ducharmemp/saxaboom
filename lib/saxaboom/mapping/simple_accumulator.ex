defmodule Saxaboom.Mapping.SimpleAccumulator do
  defstruct [:name, :attributes, children: []]

  defimpl Saxaboom.ElementCollectable do
    def element_definition(_collectable, _element), do: %{into: %@for{}}

    def cast_attributes(collectable, %{name: name, attributes: attributes}) do
      %{collectable | name: name, attributes: attributes}
    end

    def cast_characters(%{children: children} = collectable, _element, characters) do
      %{collectable | children: children ++ [characters]}
    end

    def cast_nested(%{children: children} = collectable, _element, nested) do
      %{collectable | children: children ++ [nested]}
    end
  end
end
