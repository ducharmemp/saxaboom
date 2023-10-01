defmodule SaxaboomTest.Utils.StackTest do
  use ExUnit.Case
  doctest Saxaboom.Utils.Stack

  alias Saxaboom.Utils.Stack

  describe "push/2" do
    test "can push to the stack" do
      assert [] |> Stack.push(1) |> Stack.push(2) == [2, 1]
    end
  end

  describe "pop/1" do
    test "can pop from the stack when empty" do
      assert [] |> Stack.pop() == {nil, []}
    end

    test "can pop from the stack" do
      assert [] |> Stack.push(1) |> Stack.pop() == {1, []}
    end
  end

  describe "top/1" do
    test "can get the top of the stack when empty" do
      assert [] |> Stack.top() == nil
    end

    test "can get the top of the stack" do
      assert [] |> Stack.push(1) |> Stack.top() == 1
    end
  end

  describe "swap/2" do
    test "when empty, places the item at the top of the stack" do
      assert [] |> Stack.swap(2) == [2]
    end

    test "when it holds a single item, swaps that item" do
      assert [] |> Stack.push(1) |> Stack.swap(2) == [2]
    end

    test "when multiple items are present, swaps the first item" do
      assert [] |> Stack.push(1) |> Stack.push(2) |> Stack.swap(3) == [3, 1]
    end
  end
end
