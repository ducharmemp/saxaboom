defmodule BookstoreTest do
  use ExUnit.Case
  doctest Bookstore

  test "greets the world" do
    assert Bookstore.hello() == :world
  end
end
