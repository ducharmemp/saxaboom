defmodule Bench.MixProject do
  use Mix.Project

  def project do
    [
      app: :bench,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0"},
      {:floki, "~> 0.32.0", override: true},
      {:gluttony, "0.2.0"},
      {:feedraptor, "~> 0.3.0"},
      {:feeder_ex, "~> 1.1"},
      {:saxaboom, path: "../", override: true},
      {:saxy, "~> 1.5"},
      {:erlsom, "~> 1.5", override: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
