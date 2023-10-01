defmodule Saxaboom.Element do
  @moduledoc """
  Describes an element with attributes as they are surfaced from a given parsing adapter.
  """

  @enforce_keys [:name]
  defstruct [:name, attributes: %{}]
end
