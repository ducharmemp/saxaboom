defmodule Bookstore.Book do
  use Saxaboom.Mapper

  document do
    attribute :id
    element :author
    element :title
    element :genre
    element :price, cast: :float
    element :publish_date, cast: &__MODULE__.parse_date/1
    element :description
  end

  def parse_date(value), do: Date.from_iso8601(value)
end
