defmodule Flowy.MixProject do
  use Mix.Project

  def project do
    [
      app: :flowy,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),

      # Docs
      name: "Flowy",
      source_url: "https://github.com/flowy-framework/flowy",
      homepage_url: "",
      docs: [
        # The main page in the docs
        main: "Flowy"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Flowy.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:bypass, "~> 2.1", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:excoveralls, "~> 0.15", only: :test},
      # static code analysis tool with a focus on teaching and code consistency
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      # security-focused static analysis
      {:sobelow, "~> 0.8", only: :dev},
      # scan Mix dependencies for security vulnerabilities
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21.0", only: :dev},
      # Docs
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},

      # TODO: This dependency should probably be optional
      {:finch, "~> 0.16"},
      {:oauth2, "~> 2.0"},
      {:telemetry, "~> 1.2"},
      {:prom_ex, "~> 1.9.0"}
    ]
  end
end
