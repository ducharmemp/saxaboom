defimpl Saxaboom.ElementCollectable, for: List do
  def element_definition(_collectable, _element), do: %{into: []}

  def cast_characters(collectable, _element, characters) do
    collectable ++ [characters]
  end

  def cast_element(collectable, element), do: [element | collectable]
  def cast_nested(collectable, _element, nested), do: collectable ++ [nested]
end

defmodule Support.AtomEntry do
  use Saxaboom.Mapper

  alias Saxaboom.Element

  import Saxy.XML

  document do
    element :title,
      as: :title,
      with: [type: "html"],
      into: [],
      cast: &__MODULE__.serialize_to_string/1

    element :title,
      as: :title,
      with: [type: "xhtml"],
      into: [],
      cast: &__MODULE__.serialize_to_string/1

    element :title,
      as: :title,
      with: [type: "xml"],
      into: [],
      cast: &__MODULE__.serialize_to_string/1

    element :title, as: :title
    # element :title, as: :title_type, value: :type

    element :name, as: :author
    element :content, with: [type: "xhtml"], into: [], cast: &__MODULE__.serialize_to_string/1
    element :summary
    element :enclosure, as: :image, value: :href

    element :published
    element :id, as: :entry_id
    element :created, as: :published
    element :issued, as: :published
    element :updated
    element :modified, as: :updated

    elements :category, as: :categories, value: :term

    element :link, as: :url, value: :href, with: [type: "text/html", rel: "alternate"]

    elements :link, as: :links, value: :href

    element :"media:thumbnail", as: :image, value: :url
    element :"media:content", as: :image, value: :url
  end

  defp recurse_build([%Element{name: name, attributes: attributes}]) do
    empty_element(
      name,
      # Xmerl and erlsom expand out the xmlns attribute, while saxy does not. This means that the xmlns is present
      # for re-serialization only for Saxy. For testing we want to ignore this. In production if you're
      # dealing with this sort of raw format, you'd have to account for minor parsing differences
      # between adapter libs.
      Enum.to_list(attributes) |> Enum.reject(fn {name, _val} -> name == "xmlns" end)
    )
  end

  defp recurse_build([%Element{name: name, attributes: attributes} | children]) do
    element(
      name,
      Enum.to_list(attributes) |> Enum.reject(fn {name, _val} -> name == "xmlns" end),
      children |> Enum.map(&recurse_build/1)
    )
  end

  defp recurse_build(node) do
    node
  end

  def serialize_to_string(tree) do
    dbg(tree)
    Saxy.encode!(recurse_build(tree))
  end
end

defmodule Support.PetAtomHandler do
  use Saxaboom.Mapper

  alias Support.AtomEntry

  document do
    element :subtitle, as: :description
    element :link, as: :url, value: :href, with: [type: "text/html"]
    element :link, as: :feed_url, value: :href, with: [rel: "self"]
    elements :link, as: :links, value: :href
    elements :link, as: :hubs, value: :href, with: [rel: "hub"]
    elements :entry, as: :entries, into: %AtomEntry{}
    element :icon
  end
end
