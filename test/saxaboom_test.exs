defmodule SaxaboomTest do
  use ExUnit.Case, async: true

  import Support.Utils

  doctest Saxaboom

  @adapters [:erlsom, :xmerl, :saxy]
  @test_cases [
    {"a10", Support.A10Handler}
    # {"pet_atom", Support.PetAtomHandler}
    # {"itunes"},
    # {"AmazonWebServicesBlog"}
  ]

  describe "parsing" do
    for {ex_file, ex_handler} <- @test_cases do
      test "read from string #{ex_file} #{ex_handler}" do
        results =
          for adapter <- @adapters do
            {:ok, res} =
              Saxaboom.parse(read_xml_fixture(unquote(ex_file)), %unquote(ex_handler){},
                adapter: adapter
              )

            {adapter, res}
          end

        results
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [{first_handler, first}, {second_handler, second}] ->
          IO.puts("#{first_handler}, #{second_handler}")
          assert first == second
        end)
      end
    end
  end

  describe "testerino" do
    test "whatever" do
      Saxaboom.parse(read_xml_fixture("pet_atom"), %Support.PetAtomHandler{}, adapter: :saxy)
      |> dbg()
    end
  end
end
