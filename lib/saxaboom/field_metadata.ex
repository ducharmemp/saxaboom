defmodule Saxaboom.FieldMetadata do
  @moduledoc false

  defstruct [:field_name, :element_name, :value, :with, :cast, :into, :kind, :default]

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
      cast: Access.get(opts, :cast, :noop),
      into: Access.get(opts, :into),
      kind: kind,
      default: Access.get(opts, :default)
    }
  end
end
