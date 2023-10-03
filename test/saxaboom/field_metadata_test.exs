defmodule Saxaboom.FieldMetadataTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.State

  alias Saxaboom.FieldMetadata

  describe "from/3" do
    test "it defaults to the name passed in if no `as` is provided" do

    end

    test "if an `as` is provided, it uses that as the field name" do

    end

    test "the element name is cast to a string" do

    end

    test "the value is cast to a string if provided" do

    end

    test "the value is left nil if nil" do

    end

    test "with keyword lists are converted to a map" do

    end

    test "with keyword list keys are converted to strings" do

    end

    test "with_keys are converted to strings" do

    end

    test "with_keys matches the keys of the with keyword list" do

    end

    test "cast defaults to noop if not provided" do

    end

    test "into defaults to nil if not provided" do

    end

    test "default defaults to nil if not provided" do

    end
  end

  describe "matches_attributes?/2" do
    test "it returns true if a subset of the with keyword list matches against the element attributes" do

    end

    test "it returns false if the number of attributes of the element is less than the number of attributes of the field" do

    end

    test "it returns false if the expected values do not match the attribute values" do

    end
  end
end
