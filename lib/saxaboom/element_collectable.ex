defprotocol Saxaboom.ElementCollectable do
  def element_definition(collectable, element)
  def cast_element(collectable, element)
  def cast_nested(collectable, element, nested)
end

defimpl Saxaboom.ElementCollectable, for: List do
  def element_definition(_collectable, _element), do: %{into: []}
  def cast_element(collectable, element), do: [element | collectable]
  def cast_nested(collectable, _element, nested), do: [nested | collectable]
end
