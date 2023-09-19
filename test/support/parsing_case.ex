defmodule Support.ParsingCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnitProperties

      import SaxaboomTest.Utils
    end
  end
end
