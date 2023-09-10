defmodule Astronomy do
  use Saxaboom.Mapper

  defmodule AstronomyReference do
    use Saxaboom.Mapper

    document do
      element :title
      element :year
    end
  end

  alias Astronomy.AstronomyReference

  document do
    elements :reference, as: :references, into: AstronomyReference
  end
end

defmodule AtomRss do
  use Saxaboom.Mapper

  defmodule AtomRssEntry do
    use Saxaboom.Mapper

    document do
      element :title
      element :name, as: :author
      element :content
      element :summary
      element :enclosure, as: :image, value: :href
    end
  end

  alias AtomRss.AtomRssEntry

  document do
    element :title
    element :subtitle, as: :description
    element :link, as: :url, value: :href, with: [type: "text/html"]
    element :link, as: :feed_url, value: :href, with: [rel: "self"]
    elements :link, as: :links, value: :href
    elements :link, as: :hubs, value: :href, with: [rel: "hub"]
    elements :entry, as: :entries, into: AtomRssEntry
    element :icon
  end
end

Benchee.run(
  %{
    "saxy" => fn {input, handler} -> Saxaboom.parse(input, handler, adapter: :saxy) end,
    "xmerl" => fn {input, handler} -> Saxaboom.parse(input, handler) end,
    "erlsom" => fn {input, handler} -> Saxaboom.parse(input, handler, adapter: :erlsom) end
  },
  inputs: %{
    "NASA (Large)" => {File.read!("benches/support/nasa.xml"), Astronomy},
    "Amazon Web Services Blog (Small)" =>  {File.read!("benches/support/AmazonWebServicesBlog.xml"), AtomRss}
  }
)
