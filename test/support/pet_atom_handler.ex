defmodule Support.AtomEntry do
  use Saxaboom.Mapper

  alias Saxaboom.Element

  document do
    element :title,
      as: :title,
      with: [type: "html"]

    element :title,
      as: :title,
      with: [type: "xhtml"]

    element :title,
      as: :title,
      with: [type: "xml"]

    element :title, as: :title
    # element :title, as: :title_type, value: :type

    element :name, as: :author

    element :content,
      with: [type: "xhtml"],
      default: "",
      cast: &String.trim/1

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
