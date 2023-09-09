defmodule Saxaboom.Stack do
  defstruct inner: []

  def empty?(%__MODULE__{inner: []}), do: true
  def empty?(_), do: false

  def pop(%__MODULE__{inner: []} = self), do: {nil, self}
  def pop(%__MODULE__{inner: [head | tail]} = self), do: {head, %__MODULE__{self | inner: tail}}

  def push(%__MODULE__{inner: inner} = self, value),
    do: %__MODULE__{self | inner: [value | inner]}

  def top(%__MODULE__{inner: [head | _]}), do: head

  def swap(self, value) do
    {_, self} = __MODULE__.pop(self)
    __MODULE__.push(self, value)
  end

  def size(%__MODULE__{inner: inner}), do: length(inner)
end
