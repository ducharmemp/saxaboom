defmodule Saxaboom.MixProject do
  use Mix.Project

  def project do
    [
      app: :saxaboom,
      version: "0.1.0",
      elixir: "~> 1.15",
      license: "MIT",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: test_coverage(),
      source_url: "https://github.com/ducharmemp/saxaboom"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl] ++ test_apps(Mix.env())
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:erlsom, "~> 1.5", optional: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:saxy, "~> 1.5", optional: true},
      {:stream_split, "~> 0.1.7"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp test_apps(:test), do: [:erlsom]
  defp test_apps(_), do: []

  def test_coverage() do
    [
      ignore_modules: [
        ~r/\.?Support\./,
        # This is tested indirectly by using the macros
        Saxaboom.Mapper
      ]
    ]
  end
end
