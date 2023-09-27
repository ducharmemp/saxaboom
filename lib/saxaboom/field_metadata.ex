defmodule Saxaboom.FieldMetadata do
  @moduledoc false

  alias Saxaboom.Element

  defstruct [:field_name, :element_name, :value, :with, :with_keys, :cast, :into, :kind]

  def from(name, opts, kind) do
    %__MODULE__{
      field_name: Access.get(opts, :as, name),
      element_name: to_string(name),
      value:
        case Access.get(opts, :value) do
          nil -> nil
          value -> to_string(value)
        end,
      with:
        (Access.get(opts, :with) || [])
        |> Enum.into(%{})
        |> Map.new(fn {key, value} -> {to_string(key), value} end),
      with_keys:
        (Access.get(opts, :with) || [])
        |> Enum.into(%{})
        |> Map.new(fn {key, value} -> {to_string(key), value} end)
        |> Map.keys()
        |> MapSet.new()
        |> Enum.to_list(),
      cast: Access.get(opts, :cast, :noop),
      into: Access.get(opts, :into),
      kind: kind
    }
  end

  def matches_attributes?(metadata, %Element{attributes: attributes}) do
    relevant_attributes = Map.take(attributes, metadata.with_keys)

    relevant_attributes == metadata.with
  end
end
