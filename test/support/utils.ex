defmodule Support.Utils do
  # use ExUnitProperties

  def read_xml_fixture(name) do
    ("xml/" <> name <> ".xml")
    |> read_fixture()
  end

  def stream_xml_fixture(name) do
    ("xml/" <> name <> ".xml")
    |> stream_fixture()
  end

  def read_fixture(name) do
    "test/support/fixtures/"
    |> Kernel.<>(name)
    |> Path.relative_to_cwd()
    |> File.read!()
  end

  def stream_fixture(name) do
    "test/support/fixtures/"
    |> Kernel.<>(name)
    |> Path.relative_to_cwd()
    |> File.stream!([], 100)
  end
end
