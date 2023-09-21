defmodule ITunesRSS do
  use Saxaboom.Mapper

  defmodule ITunesRSSItem do
    use Saxaboom.Mapper

    document do
      element :title

      element :"content:encoded", as: :content
      element :"a10:content", as: :content
      element :description, as: :summary

      element :link, as: :url
      element :"a10:link", as: :url, value: :href

      element :author
      element :"dc:creator", as: :author
      element :"a10:name", as: :author

      element :pubDate, as: :published
      element :pubdate, as: :published
      element :issued, as: :published
      element :"dc:date", as: :published
      element :"dc:Date", as: :published
      element :"dcterms:created", as: :published

      element :"dcterms:modified", as: :updated
      element :"a10:updated", as: :updated

      element :guid, as: :entry_id
      element :"dc:identifier", as: :dc_identifier

      element :"media:thumbnail", as: :image, value: :url
      element :"media:content", as: :image, value: :url
      element :enclosure, as: :image, value: :url

      element :comments

      elements :category, as: :categories

      # If author is not present use author tag on the item
      element :"itunes:author", as: :itunes_author
      element :"itunes:block", as: :itunes_block
      element :"itunes:duration", as: :itunes_duration
      element :"itunes:explicit", as: :itunes_explicit
      element :"itunes:keywords", as: :itunes_keywords
      element :"itunes:subtitle", as: :itunes_subtitle
      element :"itunes:image", value: :href, as: :itunes_image
      element :"itunes:isClosedCaptioned", as: :itunes_closed_captioned
      element :"itunes:order", as: :itunes_order
      element :"itunes:season", as: :itunes_season
      element :"itunes:episode", as: :itunes_episode
      element :"itunes:title", as: :itunes_title
      element :"itunes:episodeType", as: :itunes_episode_type

      # If summary is not present, use the description tag
      element :"itunes:summary", as: :itunes_summary
      element :enclosure, value: :length, as: :enclosure_length
      element :enclosure, value: :type, as: :enclosure_type
      element :enclosure, value: :url, as: :enclosure_url
      # elements "psc:chapter", as: :raw_chapters, class: Feedjira::Parser::PodloveChapter
    end
  end

  document do
    element :copyright
    element :description
    # element :image, class: RSSImage
    element :language
    element :lastBuildDate, as: :last_built
    element :link, as: :url
    element :managingEditor, as: :managing_editor
    element :rss, as: :version, value: :version
    element :title
    element :ttl

    # If author is not present use managingEditor on the channel
    element :"itunes:author", as: :itunes_author
    element :"itunes:block", as: :itunes_block
    element :"itunes:image", value: :href, as: :itunes_image
    element :"itunes:explicit", as: :itunes_explicit
    element :"itunes:complete", as: :itunes_complete
    element :"itunes:keywords", as: :itunes_keywords
    element :"itunes:type", as: :itunes_type

    # New URL for the podcast feed
    element :"itunes:new_feed_url", as: :itunes_new_feed_url
    element :"itunes:subtitle", as: :itunes_subtitle

    # If summary is not present, use the description tag
    element :"itunes:summary", as: :itunes_summary

    # iTunes RSS feeds can have multiple main categories and multiple
    # sub-categories per category.
    # elements :"itunes:category", as: :_itunes_categories,
    #                               class: ITunesRSSCategory

    # elements :"itunes:owner", as: :itunes_owners, class: ITunesRSSOwner
    elements :item, as: :entries, into: ITunesRSSItem
  end
end

data = [
  "anxiety",
  "ben",
  "daily",
  "dave",
  "stuff",
  "sleepy"
]

files = Map.new(data, fn name ->
  content = "data/#{name}.rss"
  |> Path.expand(__DIR__)
  |> File.read!()

  {name, content}
end)


bechmark = %{
  "gluttony" => &Gluttony.parse_string/1,
  "feed_raptor" => &Feedraptor.parse/1,
  "feeder_ex" => &FeederEx.parse/1,
  "saxaboom" => &Saxaboom.parse(&1, ITunesRSS, adapter: :saxy),
}

Benchee.run(bechmark,
  warmup: 5,
  time: 30,
  memory_time: 1,
  inputs: files,
  formatters: [
    Benchee.Formatters.Console
  ],
)
