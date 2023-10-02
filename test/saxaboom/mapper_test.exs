defmodule SaxaboomTest.MapperTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.Mapper

  alias Saxaboom.Element
  alias Saxaboom.ElementCollectable
  alias Support.TestHandler

  @elements [
    {%Saxaboom.Element{name: "name"}, "Some Name"},
    {%Saxaboom.Element{name: "other"}, "Renamed"},

    # Filter checks, precedence matters here to test because last text content always wins
    {%Saxaboom.Element{name: "filtered", attributes: %{kind: "text"}}, "Right"},
    {%Saxaboom.Element{name: "filtered"}, "Wrong"},

    {%Saxaboom.Element{name: "extracted", attributes: %{href: "somehref"}}, "Not extracted"},
    {%Saxaboom.Element{name: "cast"}, "1.23"},
    {%Saxaboom.Element{name: "user_cast"}, "test"},
    {%Saxaboom.Element{name: "attribute_cast", attributes: %{kind: "something"}}, ""},
    {%Saxaboom.Element{name: "some:prefix"}, "prefixed"},

    {%Saxaboom.Element{name: "precedence", attributes: %{some: "attribute", kind: "priority"}}, "order matters"},
  ]

  @expected %TestHandler{

  }

  defp reduction(_) do
  end

  describe "mapping" do
    test "it extracts the content as expected" do
      assert @expected = @elements |> Enum.reduce(%TestHandler{}, &reduction/1)
    end
  end
end
