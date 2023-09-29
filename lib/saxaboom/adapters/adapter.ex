defmodule Saxaboom.Adapters.Adapter do
  @moduledoc false

  @callback parse(xml :: term, into :: term, parser_options :: term) :: {:ok, parsed :: term}
end
