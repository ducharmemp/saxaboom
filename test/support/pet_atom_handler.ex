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

  defp recurse_build([%Element{name: name, attributes: attributes, text: text}]) do
    element(name, Enum.to_list(attributes), text)
  end

  defp recurse_build([%Element{name: name, attributes: attributes} | children]) do
    element(name, Enum.to_list(attributes), children |> Enum.map(&recurse_build/1))
  end

  def serialize_to_string([_wrapper_element | tree]) do
    Saxy.encode!(recurse_build(Enum.at(tree, 0)))
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
