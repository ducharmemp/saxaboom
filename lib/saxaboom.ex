defmodule Saxaboom do
  @moduledoc """

  """

  alias Saxaboom.Adapters

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
        Adapters.Saxy.parse(xml, into, parser_options)
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
