defmodule SaxaboomTest do
  use ExUnit.Case, async: true

  import Support.Utils

  doctest Saxaboom

  @adapters [:erlsom, :xmerl, :saxy]
  @test_cases [
    {"a10", Support.A10Handler},
    {"pet_atom", Support.PetAtomHandler}
  ]

  describe "parsing a string" do
    for {ex_file, ex_handler} <- @test_cases do
      for first_adapter <- @adapters,
          second_adapter <- @adapters,
          first_adapter != second_adapter do
        test "read from string #{ex_file} #{ex_handler}, comparing #{first_adapter} to #{second_adapter}" do
          {:ok, first_result} =
            Saxaboom.parse(read_xml_fixture(unquote(ex_file)), %unquote(ex_handler){},
              adapter: unquote(first_adapter)
            )

          {:ok, second_result} =
            Saxaboom.parse(read_xml_fixture(unquote(ex_file)), %unquote(ex_handler){},
              adapter: unquote(second_adapter)
            )

          assert first_result == second_result
        end
      end
    end
  end

  describe "streaming a file" do
    for {ex_file, ex_handler} <- @test_cases do
      for first_adapter <- @adapters,
          second_adapter <- @adapters,
          first_adapter != second_adapter do
        test "read from string #{ex_file} #{ex_handler}, comparing #{first_adapter} to #{second_adapter}" do
          {:ok, first_result} =
            Saxaboom.parse(stream_xml_fixture(unquote(ex_file)), %unquote(ex_handler){},
              adapter: unquote(first_adapter)
            )

          {:ok, second_result} =
            Saxaboom.parse(stream_xml_fixture(unquote(ex_file)), %unquote(ex_handler){},
              adapter: unquote(second_adapter)
            )

          assert first_result == second_result
        end
      end
    end
  end

  describe "dealing with bad data" do
    for adapter <- @adapters do
      test "deal with unclosed tags for #{adapter}" do
        assert_raise MatchError, ~r"no match of right hand side value", fn ->
          {:ok, _} =
            Saxaboom.parse(read_xml_fixture("unclosed_tags"), %Support.JunkHandler{},
              adapter: unquote(adapter)
            )
        end
      end
    end
  end
end
