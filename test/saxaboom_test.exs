defmodule SaxaboomTest do
  use ExUnit.Case
  doctest Saxaboom

  @adapters [:erlsom, :xmerl, :saxy]
end
