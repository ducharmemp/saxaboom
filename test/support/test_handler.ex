defmodule Support.Nested do
  use Saxaboom.Mapper

  document do
    element :id
  end
end

defmodule Support.TestHandler do
  use Saxaboom.Mapper

  alias Support.Nested

  document do
    element :name
    elements :name_item, as: :names

    element :other, as: :renamed
    elements :other_item, as: :renames

    element :filtered, with: [kind: "text"]
    elements :filtered_item, as: :filtered_items, with: [kind: "text"]

    element :extracted, value: :href
    elements :extracted_item, as: :extracts, value: :href

    element :cast, cast: :float
    elements :cast_item, as: :casts, cast: :float

    element :user_cast, cast: &__MODULE__.add_foobar/1
    elements :user_cast_item, as: :user_casts, cast: &__MODULE__.add_foobar/1

    element :attribute_cast, value: :kind, cast: &__MODULE__.add_whatever/1

    elements :attribute_cast_item,
      as: :attribute_casts,
      value: :kind,
      cast: &__MODULE__.add_whatever/1

    element :"some:prefixed", as: :prefixed
    elements :"some:prefixeditem", as: :prefixed_items

    element :precedence, as: :shouldbeset, with: [some: "attribute", kind: "priority"]
    element :precedence, as: :shouldnotbeset, with: [some: "attribute"]
    element :precedence
    elements :precedence_item, as: :shouldbeset_list, with: [some: "attribute", kind: "priority"]
    elements :precedence_item, as: :shouldnotbeset_list, with: [some: "attribute"]
    elements :precedence_item

    element :defaulted, default: 123

    elements :attribute_cast_item,
      as: :attribute_casts,
      value: :kind,
      cast: &__MODULE__.add_whatever/1

    element :nested, into: %Nested{}
    element :other_nested, as: :renamed_nested, into: %Nested{}
    element :filtered_nested, into: %Nested{}, with: [kind: "text"]

    elements :nested_item, as: :nesteds, into: %Nested{}
    elements :other_nested_item, as: :renamed_nesteds, into: %Nested{}
    elements :filtered_nested_item, as: :filtered_nesteds, into: %Nested{}, with: [kind: "text"]

    attribute :test_attribute
    attribute :test_attribute_rename, as: :renamed_attribute
    attribute :cast_attribute, cast: &__MODULE__.add_whatever/1

    attribute :same_element_1
    attribute :same_element_2
    attribute :same_element_3
    attribute :same_element_4, as: :same_element_rename
  end

  def add_foobar(value) do
    "foobar " <> value
  end

  def add_whatever(value) do
    "whatever " <> value
  end
end
