defprotocol Saxaboom.ElementCollectable do
  def element_definition(collectable, element)
  def cast_characters(collectable, element, characters)
  def cast_element(collectable, element)
  def cast_nested(collectable, element, nested)
end
