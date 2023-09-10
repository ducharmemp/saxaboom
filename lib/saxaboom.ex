defmodule Saxaboom do
  def parse(xml, into, options \\ []) do
    parser = case Keyword.get(options, :adapter, :xmerl) do
      :saxy -> &parse_saxy/2
      :erlsom -> &parse_erlsom/2
      _ -> &parse_xmerl/2
    end

    parser.(xml, into)
  end

  defp parse_saxy(xml, into) do
    if Code.ensure_loaded?(Saxy) do
      Saxaboom.Adapters.Saxy.parse(xml, into)
    else
      raise "Saxy not available, is it installed?"
    end
  end

  defp parse_erlsom(xml, into) do
    if Code.ensure_loaded?(:erlsom) do
      Saxaboom.Adapters.Erlsom.parse(xml, into)
    else
      raise "erlsom not available, is it installed?"
    end
  end

  defp parse_xmerl(xml, into) do
    Saxaboom.Adapters.Xmerl.parse(xml, into)
  end
end
