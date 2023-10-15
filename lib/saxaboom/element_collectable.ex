defprotocol Saxaboom.ElementCollectable do
  def element_definition(collectable, element)
  def attribute_definitions(collectable, element)
  def cast_characters(collectable, element, characters)
  def cast_attributes(collectable, element)
  def cast_nested(collectable, element, nested)
end
