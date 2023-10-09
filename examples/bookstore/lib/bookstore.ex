defmodule Bookstore do
  @moduledoc """
  Documentation for `Bookstore`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Bookstore.hello()
      :world

  """
  def list_books(fname) do
    Saxaboom.parse(File.read!(fname), %Bookstore.Catalog{})
  end
end
