defmodule Cardanoex.MixProject do
  use Mix.Project

  def project do
    [
      app: :cardanoex,
      version: "0.6.3",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      description: description(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
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
      {:mnemonic, "0.3.0"},
      {:tesla, "1.4.4"},
      {:hackney, "1.18.1"},
      {:jason, "1.3.0"},
      {:ex_doc, "0.28.3", only: :dev, runtime: false},
      {:inch_ex, "2.0.0", only: :docs},
      {:exvcr, "0.13.3", only: :test},
      {:excoveralls, "0.14.4"},
      {:credo, "1.6.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "1.1.0", only: [:dev], runtime: false},
      {:doctor, "0.18.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"], main: "readme"]
  end

  defp description do
    """
    Elixir client for the Cardano wallet API
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Richard Nyström"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ricn/cardanoex",
        "Docs" => "http://hexdocs.pm/cardanoex"
      }
    ]
  end
end
