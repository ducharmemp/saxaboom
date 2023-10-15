defmodule Bookstore.Catalog do
  use Saxaboom.Mapper

  alias Bookstore.Book

  document do
    elements :book, as: :books, into: %Book{}
  end
end
