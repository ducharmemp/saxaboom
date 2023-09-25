defmodule SaxaboomTest.MapperTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.Mapper

  alias Saxaboom.Element
  alias Saxaboom.ElementCollectable
  alias Support.TestHandler

  describe "single cast_element/2" do
    test "it updates the correct field" do
      sut = %TestHandler{}
      element = %Element{name: "name", text: "Some Name", attributes: %{}}
      assert ElementCollectable.cast_element(sut, element) == %TestHandler{name: "Some Name"}
    end

    test "if the element has a prefix it updates the correct field" do
      sut = %TestHandler{}
      element = %Element{name: "some:prefixed", text: "Some Name", attributes: %{}}
      assert ElementCollectable.cast_element(sut, element) == %TestHandler{prefixed: "Some Name"}
    end

    test "allows for renaming a field" do
      sut = %TestHandler{}
      element = %Element{name: "other", text: "Some Name", attributes: %{}}
      assert ElementCollectable.cast_element(sut, element) == %TestHandler{renamed: "Some Name"}
    end

    test "it can ignore elements that match on the name but don't match an attribute" do
      sut = %TestHandler{}
      element = %Element{name: "filtered", text: "Some Name", attributes: %{"kind" => "nottext"}}
      assert ElementCollectable.cast_element(sut, element) == %TestHandler{}
    end

    test "it can extract the attribute specified from the element" do
      sut = %TestHandler{}

      element = %Element{
        name: "extracted",
        text: "Some Name",
        attributes: %{"href" => "https://some.url"}
      }

      assert ElementCollectable.cast_element(sut, element) == %TestHandler{
               extracted: "https://some.url"
             }
    end

    test "it can cast the value of the element to the type specified" do
      sut = %TestHandler{}
      element = %Element{name: "cast", text: "1.45", attributes: %{}}
      assert ElementCollectable.cast_element(sut, element) == %TestHandler{cast: 1.45}
    end

    test "it can apply a transformative function to the value of the element" do
      sut = %TestHandler{}
      element = %Element{name: "user_cast", text: "spambaz", attributes: %{}}

      assert ElementCollectable.cast_element(sut, element) == %TestHandler{
               user_cast: "foobar spambaz"
             }
    end

    test "it applies transformation logic after extracting out the attributes" do
      sut = %TestHandler{}

      element = %Element{
        name: "attribute_cast",
        text: "spambaz",
        attributes: %{"kind" => "fizzbuzz"}
      }

      assert ElementCollectable.cast_element(sut, element) == %TestHandler{
               attribute_cast: "whatever fizzbuzz"
             }
    end

    test "elements with more specificity will take precedence over elements with less specificity" do
      sut = %TestHandler{}

      element = %Element{
        name: "precedence",
        text: "spambaz",
        attributes: %{"some" => "attribute", "kind" => "priority"}
      }

      assert ElementCollectable.cast_element(sut, element) == %TestHandler{
               shouldbeset: "spambaz",
               shouldnotbeset: nil,
               precedence: nil
             }
    end
  end

  describe "multiple cast_element/2" do
    test "it updates the correct field" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "name_item", text: "Some Name", attributes: %{}},
        %Element{name: "name_item", text: "Other Name", attributes: %{}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{names: ["Some Name", "Other Name"]}
    end

    test "if the element has a prefix it updates the correct field" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "some:prefixeditem", text: "Some Name", attributes: %{}},
        %Element{name: "some:prefixeditem", text: "Other Name", attributes: %{}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{prefixed_items: ["Some Name", "Other Name"]}
    end

    test "allows for renaming a field" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "other_item", text: "Some Name", attributes: %{}},
        %Element{name: "other_item", text: "Other Name", attributes: %{}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{renames: ["Some Name", "Other Name"]}
    end

    test "it ignores items that don't match the specified filter" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "filtered_item", text: "Some Name", attributes: %{"kind" => "nottext"}},
        %Element{name: "filtered_item", text: "Other Name", attributes: %{"kind" => "text"}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{filtered_items: ["Other Name"]}
    end

    test "it can extract the attribute specified from the element" do
      sut = %TestHandler{}

      elements = [
        %Element{
          name: "extracted_item",
          text: "Some Name",
          attributes: %{"href" => "https://some.url"}
        },
        %Element{
          name: "extracted_item",
          text: "Other Name",
          attributes: %{"href" => "https://someother.url"}
        }
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{extracts: ["https://some.url", "https://someother.url"]}
    end

    test "it can cast the value of the element to the type specified" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "cast_item", text: "1.45", attributes: %{}},
        %Element{name: "cast_item", text: "2.56", attributes: %{}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{casts: [1.45, 2.56]}
    end

    test "it can apply a transformative function to the value of the element" do
      sut = %TestHandler{}

      elements = [
        %Element{name: "user_cast_item", text: "spambaz", attributes: %{}},
        %Element{name: "user_cast_item", text: "blehblah", attributes: %{}}
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{user_casts: ["foobar spambaz", "foobar blehblah"]}
    end

    test "it applies transformation logic after extracting out the attributes" do
      sut = %TestHandler{}

      elements = [
        %Element{
          name: "attribute_cast_item",
          text: "Some Name",
          attributes: %{"kind" => "fizzbuzz"}
        },
        %Element{
          name: "attribute_cast_item",
          text: "Other Name",
          attributes: %{"kind" => "otherbizz"}
        }
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{
               attribute_casts: ["whatever fizzbuzz", "whatever otherbizz"]
             }
    end

    test "elements with more specificity will take precedence over elements with less specificity" do
      sut = %TestHandler{}

      elements = [
        %Element{
          name: "precedence_item",
          text: "Some Name",
          attributes: %{"some" => "attribute", "kind" => "priority"}
        },
        %Element{
          name: "precedence_item",
          text: "Other Name",
          attributes: %{"other" => "attribute"}
        }
      ]

      resolved =
        Enum.reduce(elements, sut, fn element, st ->
          ElementCollectable.cast_element(st, element)
        end)

      assert resolved == %TestHandler{
               shouldbeset_list: ["Some Name"],
               shouldnotbeset_list: nil,
               precedence_item: ["Other Name"]
             }
    end
  end

  describe "single cast_nested/3" do
    test "it updates the correct field" do
      sut = %TestHandler{}
      nested = %Support.Nested{}
      element = %Element{name: "nested", text: "Some Name", attributes: %{}}
      assert ElementCollectable.cast_nested(sut, element, nested) == %TestHandler{nested: nested}
    end

    test "allows for renaming a field" do
      sut = %TestHandler{}
      nested = %Support.Nested{}
      element = %Element{name: "other_nested", text: "Some Name", attributes: %{}}

      assert ElementCollectable.cast_nested(sut, element, nested) == %TestHandler{
               renamed_nested: nested
             }
    end

    test "it can ignore elements that match on the name but don't match an attribute" do
      sut = %TestHandler{}
      nested = %Support.Nested{}

      element = %Element{
        name: "filtered_nested",
        text: "Some Name",
        attributes: %{"kind" => "nottext"}
      }

      assert ElementCollectable.cast_nested(sut, element, nested) == %TestHandler{
               filtered_nested: nil
             }
    end
  end

  describe "multiple cast_nested/3" do
    test "it updates the correct field" do
      sut = %TestHandler{}
      nested1 = %Support.Nested{id: 1}
      nested2 = %Support.Nested{id: 2}

      elements = [
        {%Element{name: "nested_item", text: "Some Name", attributes: %{}}, nested1},
        {%Element{name: "nested_item", text: "Other Name", attributes: %{}}, nested2}
      ]

      resolved =
        Enum.reduce(elements, sut, fn {element, nested}, st ->
          ElementCollectable.cast_nested(st, element, nested)
        end)

      assert resolved == %TestHandler{nesteds: [nested1, nested2]}
    end

    test "allows for renaming a field" do
      sut = %TestHandler{}
      nested1 = %Support.Nested{id: 1}
      nested2 = %Support.Nested{id: 2}

      elements = [
        {%Element{name: "other_nested_item", text: "Some Name", attributes: %{}}, nested1},
        {%Element{name: "other_nested_item", text: "Other Name", attributes: %{}}, nested2}
      ]

      resolved =
        Enum.reduce(elements, sut, fn {element, nested}, st ->
          ElementCollectable.cast_nested(st, element, nested)
        end)

      assert resolved == %TestHandler{renamed_nesteds: [nested1, nested2]}
    end

    test "it ignores items that don't match the specified filter" do
      sut = %TestHandler{}
      nested1 = %Support.Nested{id: 1}
      nested2 = %Support.Nested{id: 2}

      elements = [
        {%Element{
           name: "filtered_nested_item",
           text: "Some Name",
           attributes: %{"kind" => "nottext"}
         }, nested1},
        {%Element{
           name: "filtered_nested_item",
           text: "Other Name",
           attributes: %{"kind" => "text"}
         }, nested2}
      ]

      resolved =
        Enum.reduce(elements, sut, fn {element, nested}, st ->
          ElementCollectable.cast_nested(st, element, nested)
        end)

      assert resolved == %TestHandler{filtered_nesteds: [nested2]}
    end
  end
end
