defmodule Saxaboom do
  @moduledoc """
  The main entrypoint for parsing a document from a string or Stream.
  """

  alias Saxaboom.Adapters

  @doc """
  Parses a given document into a user-defined struct (see: [Saxaboom.Mapper](https://hexdocs.pm/saxaboom/Saxaboom.Mapper.html) for more information)

  Takes as arguments:
    - `xml`: a string or stream of XML data
    - `into` a `Saxaboom.Mapper` type that describes the document to be parsed

  Takes as keyword arguments:
    - `adapter`: an atom describing the adapter to use when parsing the document
       - Defaults to `xmerl`
    - `parser_options`: a list of options to pass down to the chosen adapter. Refer to the parser documentation for more information.

  Returns:
    - A tuple containing the status and the parsed structure, optionally error information surfaced from the underlying parser

  """
  def parse(xml, into, options \\ []) do
    parser =
      case Keyword.get(options, :adapter, :xmerl) do
        :saxy -> &parse_saxy/3
        :erlsom -> &parse_erlsom/3
        _ -> &parse_xmerl/3
      end

    parser.(xml, into, Keyword.get(options, :parser_options, []))
  end

  if Code.ensure_loaded?(Saxy) do
    defp parse_saxy(xml, into, parser_options) do
      Adapters.Saxy.parse(xml, into, parser_options)
    end
  else
    defp parse_saxy(_xml, _into, _parser_options) do
      raise ArgumentError, """
      Saxy not available, is it installed?

      You cannot use this adapter unless it is also a dependency
      """
    end
  end

  if Code.ensure_loaded?(:erlsom) do
    defp parse_erlsom(xml, into, parser_options) do
      Adapters.Erlsom.parse(xml, into, parser_options)
    end
  else
    defp parse_erlsom(_xml, _into, _parser_options) do
      raise ArgumentError, """
      erlsom not available, is it installed?

      You cannot use this adapter unless it is also a dependency
      """
    end
  end

  defp parse_xmerl(xml, into, parser_options) do
    Adapters.Xmerl.parse(xml, into, parser_options)
  end
end
