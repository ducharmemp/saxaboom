defmodule Saxaboom.Stack do
  @compile {:inline, pop: 1}
  @compile {:inline, push: 2}
  @compile {:inline, top: 1}
  @compile {:inline, swap: 2}

  def pop([] = self), do: {nil, self}
  def pop([head | tail]), do: {head, tail}

  def push(self, value),
    do: [value | self]

  def top([]), do: nil
  def top([head | _]), do: head

  def swap([], value) do
    [value]
  end

  def swap([_], value) do
    [value]
  end

  def swap([_ | tail], value) do
    [value | tail]
  end
end
