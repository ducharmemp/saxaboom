defmodule Saxaboom.FieldMetadataTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.State

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
end
