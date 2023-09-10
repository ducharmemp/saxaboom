defmodule Saxaboom.Adapters.AdapterBehaviour do
  @callback parse(xml :: term, into :: term) :: {:ok, parsed :: term}
end
