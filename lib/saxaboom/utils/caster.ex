defmodule Saxaboom.Utils.Caster do
  @moduledoc """
  Defines semantics for standard casting mechanisms to be called after a given value has been parsed from a document.
  The current out of the box casters include:

  - `:noop` <-- the default
  - `:string`
  - `:float`
  - `:integer`
  - `:atom`
  - `:existing_atom`
  - `:boolean`
    - If the input is a string, the conversion will consider `["1", "on", "true", "yes", "y", "t"]` as truthy values and all other values as falsy
    - If the input is not a string, the conversion will force a boolean value by calling `!!` on the provided value

  If the above casters do not cover a particular case (for example, Date parsing) then a function can be provided instead
  to resolve the correct value.
  """

  def cast_value(type, value) when is_function(type) do
    type.(value)
  end

  def cast_value(:noop, value) do
    value
  end

  def cast_value(:string, value) do
    to_string(value)
  end

  def cast_value(:integer, value) do
    String.to_integer(value)
  end

  def cast_value(:float, value) do
    String.to_float(value)
  end

  def cast_value(:atom, value) do
    String.to_atom(value)
  end

  def cast_value(:existing_atom, value) do
    String.to_existing_atom(value)
  end

  def cast_value(:boolean, value) when is_binary(value) do
    Enum.member?(["1", "on", "true", "yes", "y", "t"], String.downcase(value))
  end

  def cast_value(:boolean, value) do
    !!value
  end
end
