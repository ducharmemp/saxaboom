defmodule Saxaboom.FieldMetadataTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.State

  alias Saxaboom.Element
  alias Saxaboom.FieldMetadata

  describe "from/3" do
    test "it defaults to the name passed in if no `as` is provided" do
      assert %{field_name: :something} = FieldMetadata.from(:something, [], :element)
    end

    test "if an `as` is provided, it uses that as the field name" do
      assert %{field_name: :other} = FieldMetadata.from(:something, [as: :other], :element)
    end

    test "the element name is cast to a string" do
      assert %{element_name: "something"} = FieldMetadata.from(:something, [], :element)
    end

    test "the value is cast to a string if provided" do
      assert %{value: "test"} = FieldMetadata.from(:something, [value: :test], :element)
    end

    test "the value is left nil if nil" do
      assert %{value: nil} = FieldMetadata.from(:something, [value: nil], :element)
      assert %{value: nil} = FieldMetadata.from(:something, [], :element)
    end

    test "with keyword lists are converted to a map" do
      assert %{with: %{}} = FieldMetadata.from(:something, [with: [something: :else]], :element)
    end

    test "with keyword list keys are converted to strings" do
      assert %{with: %{"something" => :else}} =
               FieldMetadata.from(:something, [with: [something: :else]], :element)
    end

    test "with_keys are converted to strings" do
      assert %{with_keys: ["something"]} =
               FieldMetadata.from(:something, [with: [something: :else]], :element)
    end

    test "with_keys matches the keys of the with keyword list" do
      meta = FieldMetadata.from(:something, [with: [something: :else]], :element)
      keys = meta.with |> Map.keys()
      assert ^keys = meta.with_keys
    end

    test "cast defaults to noop if not provided" do
      assert %{cast: :noop} = FieldMetadata.from(:something, [], :element)
    end

    test "into defaults to nil if not provided" do
      assert %{into: nil} = FieldMetadata.from(:something, [], :element)
    end

    test "default defaults to nil if not provided" do
      assert %{default: nil} = FieldMetadata.from(:something, [], :element)
    end
  end

  describe "matches_attributes?/2" do
    test "it returns true if the with matcher is empty" do
      assert true =
               FieldMetadata.from(:test, [], :element)
               |> FieldMetadata.matches_attributes?(%Element{
                 name: "",
                 attributes: %{"one" => "two", "three" => "four"}
               })
    end

    test "it returns true if a subset of the with keyword list matches against the element attributes" do
      assert true =
               FieldMetadata.from(:test, [with: [one: "two"]], :element)
               |> FieldMetadata.matches_attributes?(%Element{
                 name: "",
                 attributes: %{"one" => "two", "three" => "four"}
               })
    end

    test "it returns false if the number of attributes of the element is less than the number of attributes of the field" do
      assert false ==
               FieldMetadata.from(:test, [with: [one: "two", three: "four"]], :element)
               |> FieldMetadata.matches_attributes?(%Element{
                 name: "",
                 attributes: %{"one" => "two"}
               })
    end

    test "it returns false if the expected values do not match the attribute values" do
      assert false ==
               FieldMetadata.from(:test, [with: [one: "two"]], :element)
               |> FieldMetadata.matches_attributes?(%Element{
                 name: "",
                 attributes: %{"one" => "twofer"}
               })
    end
  end
end
