defprotocol Saxaboom.ElementCollectable do
  def element_definition(collectable, element)
  def cast_element(collectable, element)
  def cast_nested(collectable, element, nested)
end

defimpl Saxaboom.ElementCollectable, for: List do
  def element_definition(collectable, element), do: true
  def cast_element(collectable, element), do: collectable
end

defimpl Saxaboom.ElementCollectable, for: Map do
  def element_definition(collectable, element), do: true
  def cast_element(collectable, element), do: collectable
end
