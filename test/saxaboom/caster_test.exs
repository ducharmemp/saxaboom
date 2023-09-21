defmodule Saxaboom.CasterTest do
  use ExUnit.Case, async: true
  doctest Saxaboom.Caster

  alias Saxaboom.Caster

  describe "cast_value/2" do
    test "string casting" do
      # Noop
      assert Caster.cast_value(:string, "123") == "123"
    end

    test "integer casting" do
      assert Caster.cast_value(:integer, "123") == 123
    end

    test "float casting" do
      assert Caster.cast_value(:float, "1.23") == 1.23
    end

    test "atom casting" do
      assert Caster.cast_value(:atom, "test") == :test
    end

    test "existing atom casting" do
      # This passes because test2 is already defined
      assert Caster.cast_value(:existing_atom, "test2") == :test2
    end

    test "existing atom casting fails" do
      assert_raise ArgumentError, ~r"not an already existing atom", fn ->
        Caster.cast_value(:existing_atom, "test3")
      end
    end

    test "boolean casting" do
      for val <- ["1", "on", "true", "yes", "y", "t"] do
        assert Caster.cast_value(:boolean, val) == true
      end

      for val <- ["garbage", "f", "whatever", "off", "Norway"] do
        assert Caster.cast_value(:boolean, val) == false
      end
    end
  end
end
