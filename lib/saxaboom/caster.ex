defmodule Saxaboom.Caster do
  def cast_value(type, value) when is_function(type) do
    type.(value)
  end

  def cast_value(:string, value) do
    value
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

  def cast_value(:boolean, value) do
    Enum.member?(["1", "on", "true", "yes", "y", "t"], String.downcase(value))
  end
end
