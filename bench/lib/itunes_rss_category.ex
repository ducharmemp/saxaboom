defmodule ItunesRssCategory do
  use Saxaboom.Mapper

  document do
    element(:"itunes:category", as: :itunes_sub)
  end
end
