defmodule Saxaboom do
  alias Saxaboom.Adapters

  def parse(xml, into, options \\ []) do
    parser =
      case Keyword.get(options, :adapter, :xmerl) do
        :saxy -> &parse_saxy/3
        :erlsom -> &parse_erlsom/3
        _ -> &parse_xmerl/3
      end

    parser.(xml, into, Keyword.get(options, :adapter_options, []))
  end

  defp parse_saxy(xml, into, adapter_options) do
    if Code.ensure_loaded?(Saxy) do
      Adapters.Saxy.parse(xml, into, adapter_options)
    else
      raise "Saxy not available, is it installed?"
    end
  end

  defp parse_erlsom(xml, into, adapter_options) do
    if Code.ensure_loaded?(:erlsom) do
      Adapters.Erlsom.parse(xml, into, adapter_options)
    else
      raise "erlsom not available, is it installed?"
    end
  end

  defp parse_xmerl(xml, into, adapter_options) do
    Adapters.Xmerl.parse(xml, into, adapter_options)
  end
end
