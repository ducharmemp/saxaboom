defmodule ITunesRSS do
  use Saxaboom.Mapper

  document do
    element(:copyright)
    element(:description)
    # element :image, class: RSSImage
    element(:language)
    element(:lastBuildDate, as: :last_built)
    element(:link, as: :url)
    element(:managingEditor, as: :managing_editor)
    element(:rss, as: :version, value: :version)
    element(:title)
    element(:ttl)

    # If author is not present use managingEditor on the channel
    element(:"itunes:author", as: :itunes_author)
    element(:"itunes:block", as: :itunes_block)
    element(:"itunes:image", value: :href, as: :itunes_image)
    element(:"itunes:explicit", as: :itunes_explicit)
    element(:"itunes:complete", as: :itunes_complete)
    element(:"itunes:keywords", as: :itunes_keywords)
    element(:"itunes:type", as: :itunes_type)

    # New URL for the podcast feed
    element(:"itunes:new_feed_url", as: :itunes_new_feed_url)
    element(:"itunes:subtitle", as: :itunes_subtitle)

    # If summary is not present, use the description tag
    element(:"itunes:summary", as: :itunes_summary)

    # iTunes RSS feeds can have multiple main categories and multiple
    # sub-categories per category.
    # elements :"itunes:category", as: :_itunes_categories,
    #                               class: ITunesRSSCategory

    # elements :"itunes:owner", as: :itunes_owners, class: ITunesRSSOwner
    elements(:item, as: :entries, into: %ITunesRSSItem{})
  end
end
