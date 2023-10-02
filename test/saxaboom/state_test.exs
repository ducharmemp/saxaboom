defmodule Saxaboom.StateTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.State

  alias Saxaboom.State

  describe "start_element/3" do
    test "it updates the current handler" do
      state = State.initialize(%Support.SinkHandler{})

      assert %{current_handler: %{attributes: %{some: "attribute"}}} =
               State.start_element(state, "test", %{some: "attribute"})
    end

    test "when a nested handler is not necessary, it leaves the current handler as-is" do
      handler = %Support.SinkHandler{}
      state = State.initialize(handler)

      assert %{current_handler: ^handler, handler_stack: []} =
               State.start_element(state, "test", %{})
    end

    test "when a nested handler is necessary, it updates the nested handler" do
      nested = %Support.SinkHandler{}
      handler = %Support.SinkHandler{element_definition: %{into: nested}}
      state = State.initialize(handler)

      assert %{
               current_handler: %Support.SinkHandler{
                 element_definition: nil,
                 attributes: %{some: "attribute"}
               }
             } = State.start_element(state, "test", %{some: "attribute"})
    end

    test "when a nested handler is necessary, it pushes the previous handler onto the stack" do
      nested = %Support.SinkHandler{}
      handler = %Support.SinkHandler{element_definition: %{into: nested}}
      state = State.initialize(handler)

      assert %{handler_stack: [{-1, ^handler}]} =
               State.start_element(state, "test", %{some: "attribute"})
    end

    test "it updates the current element" do
      assert %{current_element: %{name: "test2"}} =
               State.initialize(%Support.SinkHandler{})
               |> State.start_element("test", %{})
               |> State.start_element("test2", %{})
    end

    test "it pushes the previous element onto the stack" do
      assert %{element_stack: [%{name: "test"}, %{name: "document"}]} =
               State.initialize(%Support.SinkHandler{})
               |> State.start_element("test", %{})
               |> State.start_element("test2", %{})
    end
  end

  describe "end_element/2" do
    test "when closing an element that required a nested handler, it pops the nested handler off the stack" do
      nested = %Support.SinkHandler{}
      handler = %Support.SinkHandler{element_definition: %{into: nested}}

      assert %{handler_stack: []} =
               State.initialize(handler)
               |> State.start_element("test", %{some: "attribute"})
               |> State.end_element("test")
    end

    test "when closing an element that required a nested handler, it calls the handler to receive a nested struct" do
      nested = %Support.SinkHandler{}
      handler = %Support.SinkHandler{element_definition: %{into: nested}}

      assert %{current_handler: %{nested: ^nested}} =
               State.initialize(handler)
               |> State.start_element("test", %{})
               |> State.end_element("test")
    end

    test "when closing an element, it pops the parent element off the stack" do
      handler = %Support.SinkHandler{}

      assert %{element_stack: [%{name: "document"}]} =
               State.initialize(handler)
               |> State.start_element("test", %{some: "attribute"})
               |> State.start_element("test2", %{})
               |> State.end_element("test2")
    end

    test "when closing an element, it updates the current element" do
      handler = %Support.SinkHandler{}

      assert %{current_element: %{name: "test"}} =
               State.initialize(handler)
               |> State.start_element("test", %{some: "attribute"})
               |> State.start_element("test2", %{})
               |> State.end_element("test2")
    end
  end

  describe "characters/2" do
    test "it updates the current handler" do
      handler = %Support.SinkHandler{}

      assert %{current_handler: %{characters: "test characters"}} =
        State.initialize(handler)
        |> State.start_element("test", %{})
        |> State.characters("test characters")
    end
  end

  describe "finish/1" do
    test "it returns the current handler" do
      handler = %Support.SinkHandler{}

      assert %Support.SinkHandler{attributes: %{some: "attributes"}} =
        State.initialize(handler)
        |> State.start_element("test", %{some: "attributes"})
        |> State.finish()
    end
  end
end
