defmodule Support.A10Author do
  use Saxaboom.Mapper

  document do
    element :"a10:name", as: :name
    element :"a10:uri", as: :uri
    element :"a10:email", as: :email
  end
end

defmodule Support.A10Item do
  use Saxaboom.Mapper

  alias Support.A10Author

  document do
    element :title
    element :description
    element :pubDate, as: :updated
    element :"a10:link", as: :link
    element :"a10:author", as: :author, into: %A10Author{}
  end
end

defmodule Support.A10Handler do
  use Saxaboom.Mapper

  alias Support.A10Item

  document do
    element :title
    element :description
    element :lastBuildDate
    element :category
    element :"a10:link", as: :link, value: :href
    element :pubDate, as: :updated
    elements :item, as: :items, into: %A10Item{}
  end
end
