defmodule ITunesRSSItem do
  use Saxaboom.Mapper

  document do
    element(:title)

    element(:"content:encoded", as: :content)
    element(:"a10:content", as: :content)
    element(:description, as: :summary)

    element(:link, as: :url)
    element(:"a10:link", as: :url, value: :href)

    element(:author)
    element(:"dc:creator", as: :author)
    element(:"a10:name", as: :author)

    element(:pubDate, as: :published)
    element(:pubdate, as: :published)
    element(:issued, as: :published)
    element(:"dc:date", as: :published)
    element(:"dc:Date", as: :published)
    element(:"dcterms:created", as: :published)

    element(:"dcterms:modified", as: :updated)
    element(:"a10:updated", as: :updated)

    element(:guid, as: :entry_id)
    element(:"dc:identifier", as: :dc_identifier)

    element(:"media:thumbnail", as: :image, value: :url)
    element(:"media:content", as: :image, value: :url)
    element(:enclosure, as: :image, value: :url)

    element(:comments)

    elements(:category, as: :categories)

    # If author is not present use author tag on the item
    element(:"itunes:author", as: :itunes_author)
    element(:"itunes:block", as: :itunes_block)
    element(:"itunes:duration", as: :itunes_duration)
    element(:"itunes:explicit", as: :itunes_explicit)
    element(:"itunes:keywords", as: :itunes_keywords)
    element(:"itunes:subtitle", as: :itunes_subtitle)
    element(:"itunes:image", value: :href, as: :itunes_image)
    element(:"itunes:isClosedCaptioned", as: :itunes_closed_captioned)
    element(:"itunes:order", as: :itunes_order)
    element(:"itunes:season", as: :itunes_season)
    element(:"itunes:episode", as: :itunes_episode)
    element(:"itunes:title", as: :itunes_title)
    element(:"itunes:episodeType", as: :itunes_episode_type)

    # If summary is not present, use the description tag
    element(:"itunes:summary", as: :itunes_summary)
    element(:enclosure, value: :length, as: :enclosure_length)
    element(:enclosure, value: :type, as: :enclosure_type)
    element(:enclosure, value: :url, as: :enclosure_url)
    # elements "psc:chapter", as: :raw_chapters, class: Feedjira::Parser::PodloveChapter
  end
end
