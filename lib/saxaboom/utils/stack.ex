defmodule Saxaboom.Utils.Stack do
  @moduledoc false

  @compile {:inline, pop: 1}
  @compile {:inline, push: 2}
  @compile {:inline, top: 1}

  def pop([] = self), do: {nil, self}
  def pop([head | tail]), do: {head, tail}

  def push(self, value),
    do: [value | self]

  def top([]), do: nil
  def top([head | _]), do: head
end
