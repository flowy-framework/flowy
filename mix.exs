defmodule Flowy.MixProject do
  use Mix.Project

  @repo_url "https://github.com/flowy-framework/flowy"
  @name "Flowy"
  @version "0.1.8"

  def project do
    [
      app: :flowy,
      version: @version,
      elixir: "~> 1.14",
      description: "A modern framework that promises a smooth developer experience.",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      # Docs
      name: @name,
      source_url: @repo_url,
      homepage_url: "https://hex.pm/packages/flowy",
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Flowy.Application, []}
    ]
  end

  defp docs do
    [
      logo: "assets/logo-small.png",
      source_ref: "v#{@version}",
      source_url: @repo_url,
      main: @name,
      extras: []
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @repo_url
      },
      files: ~w(priv)
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
      {:telemetry, "~> 1.2"},
      {:prom_ex, "~> 1.9.0"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_live_view, "~> 0.20.0"},
      # Database
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:recase, "~> 0.7"},

      # Auth
      {:joken, "~> 2.5"},
      {:oauth2, "~> 2.0"}
    ]

    # ++ private_deps()
  end

  def private_deps() do
    [
      {"../paleta", :paleta_dep}
    ]
    |> Enum.map(fn {path, fun} ->
      apply(__MODULE__, fun, [File.exists?(path) && local_dev?()])
    end)
    |> List.flatten()
  end

  def local_dev?() do
    Mix.env() == :dev || Mix.env() == :test
  end

  def paleta_dep(true = _local) do
    [{:paleta, path: "../paleta"}]
  end

  def paleta_dep(false) do
    [
      {:paleta, "~> 0.1.0"}
    ]
  end
end
