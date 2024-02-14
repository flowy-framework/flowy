defmodule <%= @app_module %>.MixProject do
  use Mix.Project

  def project do
    [
      app: :<%= @app_name %>,
      version: "0.1.0",<%= if @in_umbrella do %>
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",<% end %>
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),

      # Hex
      package: package(),

      # Docs
      name: "<%= @app_module %>",
      source_url: "",
      homepage_url: "",
      docs: [
        # The main page in the docs
        main: "<%= @app_module %>",
        extra_section: "GUIDES",
        extras: extras(),
        groups_for_extras: groups_for_extras()
      ]
    ]
  end

  defp extras do
    [
      "docs/guides/directory_structure.md",
    ]
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* CHANGELOG* LICENSE*)
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r/docs\/guides\/[^\/]+\.md/
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {<%= @app_module %>.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      <%= @phoenix_dep %>,<%= if @ecto do %>
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {<%= inspect @adapter_app %>, ">= 0.0.0"},<% end %><%= if @html do %>
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:floki, ">= 0.30.0", only: :test},<% end %><%= if @dashboard do %>
      {:phoenix_live_dashboard, "~> 0.8.2"},<% end %><%= if @javascript do %>
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},<% end %><%= if @css do %>
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},<% end %><%= if @mailer do %>
      {:swoosh, "~> 1.14"},
      {:finch, "~> 0.16"},<% end %><%= if @gettext do %>
      {:gettext, "~> 0.23"},<% end %>
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {<%= inspect @web_adapter_app %>, "<%= @web_adapter_vsn %>"},

      # flowy
      {:casex, git: "https://github.com/livesup-dev/casex", tag: "0.4.3"},

      # Opentelemetry
      {:opentelemetry_exporter, "~> 1.6.0"},
      {:opentelemetry, "~> 1.3.0"},
      {:opentelemetry_api, "~> 1.2.0"},
      {:opentelemetry_ecto, "~> 1.1.0"},
      {:opentelemetry_phoenix, "~> 1.1.0"},
      {:opentelemetry_liveview, "~> 1.0.0-rc.4"},
      {:logger_json, "~> 5.1"},

      # Monitoring
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:ecto_psql_extras, "~> 0.7"},

      # Security check
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: true},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},

      # Test coverage
      {:excoveralls, "~> 0.18", only: :test},

      # Testing tools
      {:faker, "~> 0.17", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},

      # Docs
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:open_api_spex, "~> 3.16"},

      # Jobs
      {:oban, "~> 2.15"},
      {:paleta, git: "https://github.com/flowy-framework/paleta", tag: "latest"},
      {:flowy, git: "https://github.com/flowy-framework/flowy", tag: "latest"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"<%= if @ecto do %>, "ecto.setup"<% end %><%= if @asset_builders != [] do %>, "assets.setup", "assets.build"<% end %>]<%= if @ecto do %>,
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reset.db": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]<% end %><%= if @asset_builders != [] do %>,
      "assets.setup": <%= inspect Enum.map(@asset_builders, &"#{&1}.install --if-missing") %>,
      "assets.build": <%= inspect Enum.map(@asset_builders, &"#{&1} default") %>,
      "assets.deploy": <%= inspect Enum.map(@asset_builders, &"#{&1} default --minify") ++ ["phx.digest"] %><% end %>
    ]
  end
end
