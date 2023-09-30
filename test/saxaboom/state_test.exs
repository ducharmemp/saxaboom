defmodule Saxaboom.StateTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.State

  alias Saxaboom.Element
  alias Saxaboom.State
  alias Support.TestHandler

  describe "handle_cast/2 :start_element" do
    test "when a nested handler is not necessary it does not reply to the caller and returns the handler stack as is" do
      handler_stack = [{0, %TestHandler{}}]

      assert {:noreply,
              %{
                element_stack: [%Element{name: "name", attributes: %{}}],
                handler_stack: ^handler_stack
              }} =
               State.handle_cast({:start_element, "name", %{}}, %{
                 element_stack: [],
                 handler_stack: handler_stack
               })
    end

    test "when a nested handler is necessary it does not reply to the caller and returns an updated handler stack" do
      handler_stack = [{0, %TestHandler{}}]

      assert {:noreply,
              %{
                element_stack: [%Element{name: "nested", attributes: %{}}],
                handler_stack: [{1, %Support.Nested{}}, {0, %TestHandler{}}]
              }} =
               State.handle_cast({:start_element, "nested", %{}}, %{
                 element_stack: [],
                 handler_stack: handler_stack
               })
    end
  end

  describe "handle_cast/2 :end_element" do
    test "when terminating an unknown element, it does not reply to the caller and returns the handler stack as is" do
      handler_stack = [{0, %TestHandler{}}]

      assert {:noreply, %{element_stack: [], handler_stack: ^handler_stack}} =
               State.handle_cast({:end_element, "unknown"}, %{
                 element_stack: [%Element{name: "unknown", attributes: %{}}],
                 handler_stack: handler_stack
               })
    end

    test "when terminating a known element, it updates the given handler" do
      handler_stack = [{0, %TestHandler{}}]

      assert {:noreply, %{element_stack: [], handler_stack: [{0, %TestHandler{name: "foobar"}}]}} =
               State.handle_cast({:end_element, "name"}, %{
                 element_stack: [%Element{name: "name", text: "foobar", attributes: %{}}],
                 handler_stack: handler_stack
               })
    end

    test "when terminating a nested element, it removes the handler from the stack" do
      handler_stack = [{1, %Support.Nested{}}, {0, %TestHandler{}}]

      assert {:noreply, %{element_stack: [], handler_stack: [{0, %TestHandler{}}]}} =
               State.handle_cast({:end_element, "nested"}, %{
                 element_stack: [%Element{name: "nested", attributes: %{}}],
                 handler_stack: handler_stack
               })
    end
  end

  describe "handle_call/2 :finish" do
    test "replies to the caller and gets the top of the stack" do
      handler_stack = [{0, %TestHandler{}}]

      assert {:reply, %TestHandler{}, []} =
               State.handle_call({:finish}, nil, %{
                 element_stack: [],
                 handler_stack: handler_stack
               })
    end
  end
end
