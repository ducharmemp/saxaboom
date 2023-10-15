defmodule SaxaboomTest.MapperTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.Mapper

  alias Saxaboom.ElementCollectable
  alias Support.TestHandler

  @elements [
    {%Saxaboom.Element{name: "name"}, "Some name"},
    {%Saxaboom.Element{name: "name_item"}, "Some name item"},
    {%Saxaboom.Element{name: "other"}, "Renamed"},
    {%Saxaboom.Element{name: "other_item"}, "Renamed item"},

    # Filter checks, precedence matters here to test because last text content always wins
    {%Saxaboom.Element{name: "filtered", attributes: %{"kind" => "text"}}, "Right"},
    {%Saxaboom.Element{name: "filtered"}, "Wrong"},
    {%Saxaboom.Element{name: "filtered_item", attributes: %{"kind" => "text"}}, "Right item"},
    {%Saxaboom.Element{name: "filtered_item"}, "Wrong item"},
    {%Saxaboom.Element{name: "extracted", attributes: %{"href" => "somehref"}}, "Not extracted"},
    {%Saxaboom.Element{name: "extracted_item", attributes: %{"href" => "somehref"}},
     "Not extracted"},
    {%Saxaboom.Element{name: "cast"}, "1.23"},
    {%Saxaboom.Element{name: "cast_item"}, "1.23"},
    {%Saxaboom.Element{name: "user_cast"}, "test"},
    {%Saxaboom.Element{name: "user_cast_item"}, "test"},
    {%Saxaboom.Element{name: "attribute_cast", attributes: %{"kind" => "something"}},
     "shouldn't be"},
    {%Saxaboom.Element{name: "attribute_cast_item", attributes: %{"kind" => "something"}},
     "shouldn't be"},
    {%Saxaboom.Element{name: "some:prefixed"}, "prefixed"},
    {%Saxaboom.Element{name: "some:prefixeditem"}, "prefixed item"},
    {%Saxaboom.Element{
       name: "precedence",
       attributes: %{"some" => "attribute", "kind" => "priority"}
     }, "order matters"},
    {%Saxaboom.Element{
       name: "precedence_item",
       attributes: %{"some" => "attribute", "kind" => "priority"}
     }, "order matters"},
    {%Saxaboom.Element{name: "nested"}, "", %Support.Nested{id: "nested"}},
    {%Saxaboom.Element{name: "nested_item"}, "", %Support.Nested{id: "nested item"}},
    {%Saxaboom.Element{name: "other_nested"}, "", %Support.Nested{id: "renamed nested"}},
    {%Saxaboom.Element{name: "other_nested_item"}, "", %Support.Nested{id: "renamed nested"}},
    {%Saxaboom.Element{name: "filtered_nested", attributes: %{"kind" => "text"}}, "",
     %Support.Nested{id: "filtered nested"}},
    {%Saxaboom.Element{name: "filtered_nested"}, "",
     %Support.Nested{id: "wrong filtered nested"}},
    {%Saxaboom.Element{name: "filtered_nested_item", attributes: %{"kind" => "text"}}, "",
     %Support.Nested{id: "filtered nested item"}},
    {%Saxaboom.Element{name: "filtered_nested_item"}, "",
     %Support.Nested{id: "wrong filtered nested item"}},
    {%Saxaboom.Element{name: "does_not_matter", attributes: %{"test_attribute" => "attribute"}},
     "nope"},
    {%Saxaboom.Element{
       name: "does_not_matter",
       attributes: %{"test_attribute_rename" => "attribute rename"}
     }, "nope"},
    {%Saxaboom.Element{
       name: "does_not_matter",
       attributes: %{"cast_attribute" => "attribute cast"}
     }, "nope"},
    {%Saxaboom.Element{
       name: "does_not_matter",
       attributes: %{
         "same_element_1" => "one",
         "same_element_2" => "two",
         "same_element_3" => "three",
         "same_element_4" => "four"
       }
     }, "nope"}
  ]

  @expected %Support.TestHandler{
    attribute_cast: "whatever something",
    attribute_casts: ["whatever something", "whatever something"],
    cast: 1.23,
    casts: [1.23],
    defaulted: 123,
    extracted: "somehref",
    extracts: ["somehref", "somehref"],
    filtered: "Right",
    filtered_items: ["Right item"],
    filtered_nested: %Support.Nested{id: "filtered nested"},
    filtered_nesteds: [%Support.Nested{id: "filtered nested item"}],
    name: "Some name",
    names: ["Some name item"],
    nested: %Support.Nested{id: "nested"},
    nesteds: [%Support.Nested{id: "nested item"}],
    precedence: nil,
    precedence_item: [],
    prefixed: "prefixed",
    prefixed_items: ["prefixed item"],
    renamed: "Renamed",
    renamed_nested: %Support.Nested{id: "renamed nested"},
    renamed_nesteds: [%Support.Nested{id: "renamed nested"}],
    renames: ["Renamed item"],
    shouldbeset: "order matters",
    shouldbeset_list: ["order matters"],
    shouldnotbeset: nil,
    shouldnotbeset_list: [],
    user_cast: "foobar test",
    user_casts: ["foobar test"],
    test_attribute: "attribute",
    renamed_attribute: "attribute rename",
    cast_attribute: "whatever attribute cast",
    same_element_1: "one",
    same_element_2: "two",
    same_element_3: "three",
    same_element_rename: "four"
  }

  defp reduction({element, _, nested}, handler) do
    handler
    |> ElementCollectable.cast_nested(element, nested)
  end

  defp reduction({element, text}, handler) do
    handler
    |> ElementCollectable.cast_attributes(element)
    |> ElementCollectable.cast_characters(element, text)
  end

  describe "mapping" do
    test "it extracts the content as expected" do
      assert @expected = @elements |> Enum.reduce(%TestHandler{}, &reduction/2)
    end
  end
end
