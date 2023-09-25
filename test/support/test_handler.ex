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
    element :other, as: :renamed
    element :filtered, with: [kind: "text"]
    element :extracted, value: :href
    element :cast, cast: :float
    element :user_cast, cast: &__MODULE__.add_foobar/1
    element :attribute_cast, value: :kind, cast: &__MODULE__.add_whatever/1
    element :"some:prefixed", as: :prefixed
    element :precedence, as: :shouldbeset, with: [some: "attribute", kind: "priority"]
    element :precedence, as: :shouldnotbeset, with: [some: "attribute"]
    element :precedence

    elements :name_item, as: :names
    elements :other_item, as: :renames
    elements :filtered_item, as: :filtered_items, with: [kind: "text"]
    elements :extracted_item, as: :extracts, value: :href
    elements :cast_item, as: :casts, cast: :float
    elements :user_cast_item, as: :user_casts, cast: &__MODULE__.add_foobar/1
    elements :"some:prefixeditem", as: :prefixed_items
    elements :precedence_item, as: :shouldbeset_list, with: [some: "attribute", kind: "priority"]
    elements :precedence_item, as: :shouldnotbeset_list, with: [some: "attribute"]
    elements :precedence_item

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
  end

  def add_foobar(value) do
    "foobar " <> value
  end

  def add_whatever(value) do
    "whatever " <> value
  end
end
