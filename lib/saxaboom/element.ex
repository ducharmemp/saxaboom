defmodule Saxaboom.Element do
  @moduledoc """

  """

  @enforce_keys [:name]
  defstruct [:name, attributes: %{}, text: nil]
end
