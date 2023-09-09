defmodule Saxaboom.Element do
  @enforce_keys [:name]
  defstruct [:name, attributes: %{}, text: nil]
end
