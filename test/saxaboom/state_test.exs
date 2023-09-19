defmodule Saxaboom.StateTest do
  use ExUnit.Case
  doctest Saxaboom.State

  alias Saxaboom.State
  alias Saxaboom.Element
  alias Support.TestHandler

  describe "handle_cast/2 :start_element" do
    test "when a nested handler is not necessary it does not reply to the caller and returns the handler stack as is" do
      handler_stack = [{0, %TestHandler{}}]
      element = %Element{name: "name", attributes: %{}}
      depth = 1

      assert {:noreply, ^handler_stack} = State.handle_cast({:start_element, element, depth}, handler_stack)
    end

    test "when a nested handler is necessary it does not reply to the caller and returns an updated handler stack" do
      handler_stack = [{0, %TestHandler{}}]
      element = %Element{name: "nested", attributes: %{}}
      depth = 1

      assert {:noreply, [{1, %TestHandler.Nested{}}, {0, %TestHandler{}}]} = State.handle_cast({:start_element, element, depth}, handler_stack)
    end
  end

  describe "handle_cast/2 :end_element" do
    test "when terminating an unknown element, it does not reply to the caller and returns the handler stack as is" do
      handler_stack = [{0, %TestHandler{}}]
      element = %Element{name: "unknown", attributes: %{}}
      depth = 1

      assert {:noreply, ^handler_stack} = State.handle_cast({:end_element, element, depth}, handler_stack)
    end

    test "when terminating a known element, it updates the given handler" do
      handler_stack = [{0, %TestHandler{}}]
      element = %Element{name: "name", attributes: %{}, text: "foobar"}
      depth = 1

      assert {:noreply, [{0, %TestHandler{name: "foobar"}}]} = State.handle_cast({:end_element, element, depth}, handler_stack)
    end

    test "when terminating a nested element, it removes the handler from the stack" do
      handler_stack = [{1, %TestHandler.Nested{}}, {0, %TestHandler{}}]
      element = %Element{name: "nested", attributes: %{}}
      depth = 1

      assert {:noreply, [{0, %TestHandler{}}]} = State.handle_cast({:end_element, element, depth}, handler_stack)
    end
  end

  describe "handle_call/2 :finish" do
    test "replies to the caller and gets the top of the stack" do
      handler_stack = [{0, %TestHandler{}}]
      assert %TestHandler{} = State.handle_call({:finish}, nil, handler_stack)
    end
  end
end
