defprotocol Saxaboom.ElementCollectable do
  @moduledoc """

  """

  def element_definition(collectable, element)
  def cast_element(collectable, element)
  def cast_nested(collectable, element, nested)
end