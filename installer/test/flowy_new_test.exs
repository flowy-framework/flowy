Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Flowy.NewTest do
  use ExUnit.Case, async: false
  import MixHelper
  import ExUnit.CaptureIO

  @app_name "flowy_app"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send(self(), {:mix_shell_input, :yes?, false})
    :ok
  end

  test "assets are in sync with priv" do
    for file <- ~w(favicon.ico phoenix.png) do
      assert File.read!("../priv/static/#{file}") ==
               File.read!("templates/phx_static/#{file}")
    end
  end

  test "returns the version" do
    Mix.Tasks.Flowy.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Flowy installer v" <> _]}
  end

  test "new with defaults" do
    in_tmp("new with defaults", fn ->
      Mix.Tasks.Flowy.New.run([@app_name])

      assert_file("flowy_app/README.md", fn file ->
        assert file =~ "# FlowyApp powered by Flowy"
      end)

      assert_file("flowy_app/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:open_api_spex, :ecto, :ecto_sql, :phoenix]"
        assert file =~ "subdirectories: [\"priv/*/migrations\"]"
        assert file =~ "plugins: [Phoenix.LiveView.HTMLFormatter]"

        assert file =~
                 "inputs: [\"*.{heex,ex,exs}\", \"{config,lib,test}/**/*.{heex,ex,exs}\", \"priv/*/seeds.exs\"]"
      end)

      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "app: :flowy_app"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end)

      assert_file("flowy_app/config/config.exs", fn file ->
        assert file =~ "ecto_repos: [FlowyApp.Repo]"
        assert file =~ "generators: [timestamp_type: :utc_datetime]"
        assert file =~ "config :phoenix, :json_library, Jason"
        assert file =~ ~s[cd: Path.expand("../assets", __DIR__),]
        refute file =~ "namespace: FlowyApp"
        refute file =~ "config :flowy_app, :generators"
      end)

      assert_file("flowy_app/config/prod.exs", fn file ->
        assert file =~ "config :logger, level: :info"
      end)

      assert_file("flowy_app/config/runtime.exs", ~r/ip: {0, 0, 0, 0, 0, 0, 0, 0}/)

      assert_file("flowy_app/lib/flowy_app/application.ex", ~r/defmodule FlowyApp.Application do/)
      assert_file("flowy_app/lib/flowy_app.ex", ~r/defmodule FlowyApp do/)

      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "mod: {FlowyApp.Application, []}"
        assert file =~ "{:jason,"
        assert file =~ "{:phoenix_live_dashboard,"
      end)

      assert_file("flowy_app/lib/flowy_app_web.ex", fn file ->
        assert file =~ "defmodule FlowyAppWeb do"
        assert file =~ "import Phoenix.HTML"
        assert file =~ "Phoenix.LiveView"
      end)

      assert_file("flowy_app/test/flowy_app_web/controllers/page_controller_test.exs")
      assert_file("flowy_app/test/flowy_app_web/controllers/error_html_test.exs")
      assert_file("flowy_app/test/flowy_app_web/controllers/error_json_test.exs")
      assert_file("flowy_app/test/support/conn_case.ex")
      assert_file("flowy_app/test/test_helper.exs")

      assert_file(
        "flowy_app/lib/flowy_app_web/controllers/page_controller.ex",
        ~r/defmodule FlowyAppWeb.PageController/
      )

      assert_file(
        "flowy_app/lib/flowy_app_web/controllers/page_html.ex",
        ~r/defmodule FlowyAppWeb.PageHTML/
      )

      assert_file(
        "flowy_app/lib/flowy_app_web/controllers/error_html.ex",
        ~r/defmodule FlowyAppWeb.ErrorHTML/
      )

      assert_file(
        "flowy_app/lib/flowy_app_web/controllers/error_json.ex",
        ~r/defmodule FlowyAppWeb.ErrorJSON/
      )

      assert_file("flowy_app/lib/flowy_app_web/components/layouts.ex", fn file ->
        assert file =~ "defmodule FlowyAppWeb.Layouts"
      end)

      assert_file("flowy_app/lib/flowy_app_web/router.ex", fn file ->
        assert file =~ "defmodule FlowyAppWeb.Router"
        assert file =~ "live_dashboard"
        assert file =~ "import Phoenix.LiveDashboard.Router"
      end)

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule FlowyAppWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("flowy_app/lib/flowy_app_web/components/layouts/root.html.heex", fn file ->
        assert file =~ ~s|<meta name="csrf-token" content={get_csrf_token()} />|
      end)

      assert_file("flowy_app/lib/flowy_app_web/components/layouts/app.html.heex")
      assert_file("flowy_app/lib/flowy_app_web/controllers/page_html/home.html.heex")

      # assets
      assert_file("flowy_app/priv/static/images/logo.png")

      assert_file("flowy_app/.gitignore", fn file ->
        assert file =~ "/priv/static/assets/"
        assert file =~ "flowy_app-*.tar"
        assert file =~ ~r/\n$/
      end)

      assert_file("flowy_app/config/dev.exs", fn file ->
        assert file =~ "esbuild: {Esbuild,"
        assert file =~ "lib/flowy_app_web/(controllers|live|components)/.*(ex|heex)"
      end)

      # tailwind
      assert_file("flowy_app/assets/css/app.css")
      assert_file "flowy_app/assets/tailwind.config.js", fn file ->
        assert file =~ "flowy_app_web.ex"
        assert file =~ "flowy_app_web/**/*.*ex"
      end

      assert_file("flowy_app/assets/vendor/heroicons/LICENSE.md")
      assert_file("flowy_app/assets/vendor/heroicons/UPGRADE.md")
      assert_file("flowy_app/assets/vendor/heroicons/optimized/24/outline/cake.svg")
      assert_file("flowy_app/assets/vendor/heroicons/optimized/24/solid/cake.svg")
      assert_file("flowy_app/assets/vendor/heroicons/optimized/20/solid/cake.svg")

      refute File.exists?("flowy_app/priv/static/assets/app.css")
      refute File.exists?("flowy_app/priv/static/assets/app.js")
      assert File.exists?("flowy_app/assets/vendor")

      assert_file("flowy_app/config/config.exs", fn file ->
        assert file =~ "cd: Path.expand(\"../assets\", __DIR__)"
        assert file =~ "config :esbuild"
      end)

      # Ecto
      config = ~r/config :flowy_app, FlowyApp.Repo,/

      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "{:phoenix_ecto,"
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end)

      assert_file("flowy_app/config/dev.exs", config)
      assert_file("flowy_app/config/test.exs", config)

      assert_file("flowy_app/config/runtime.exs", fn file ->
        assert file =~ config

        assert file =~
                 ~S|maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []|

        assert file =~ ~S|socket_options: maybe_ipv6|

        assert file =~ """
               if System.get_env("PHX_SERVER") do
                 config :flowy_app, FlowyAppWeb.Endpoint, server: true
               end
               """

        assert file =~ ~S[host = System.get_env("PHX_HOST") || "example.com"]
        assert file =~ ~S|url: [host: host, port: 443, scheme: "https"],|
      end)

      assert_file(
        "flowy_app/config/test.exs",
        ~R/database: "flowy_app_test#\{System.get_env\("MIX_TEST_PARTITION"\)\}"/
      )

      assert_file("flowy_app/lib/flowy_app/repo.ex", ~r"defmodule FlowyApp.Repo")
      assert_file("flowy_app/lib/flowy_app_web.ex", ~r"defmodule FlowyAppWeb")

      assert_file(
        "flowy_app/lib/flowy_app_web/endpoint.ex",
        ~r"plug Phoenix.Ecto.CheckRepoStatus, otp_app: :flowy_app"
      )

      assert_file("flowy_app/priv/repo/seeds.exs", ~r"FlowyApp.Repo.insert!")
      assert_file("flowy_app/test/support/data_case.ex", ~r"defmodule FlowyApp.DataCase")
      assert_file("flowy_app/priv/repo/migrations/.formatter.exs", ~r"import_deps: \[:ecto_sql\]")
      assert_file("flowy_app/priv/repo/migrations/20230906161135_add_oban_jobs_table.exs")

      # LiveView
      refute_file("flowy_app/lib/flowy_app_web/live/page_live_view.ex")

      assert_file("flowy_app/assets/js/app.js", fn file ->
        assert file =~ ~s|import {LiveSocket} from "phoenix_live_view"|
        assert file =~ ~s|liveSocket.connect()|
      end)

      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ ~r":phoenix_live_view"
        assert file =~ ~r":floki"
      end)

      assert_file(
        "flowy_app/lib/flowy_app_web/router.ex",
        &assert(&1 =~ ~s[plug :fetch_live_flash])
      )

      assert_file("flowy_app/lib/flowy_app_web/router.ex", &assert(&1 =~ ~s[plug :put_root_layout]))
      assert_file("flowy_app/lib/flowy_app_web/router.ex", &assert(&1 =~ ~s[PageController]))

      # Telemetry
      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "{:telemetry_metrics,"
        assert file =~ "{:telemetry_poller,"
      end)

      assert_file("flowy_app/lib/flowy_app_web/telemetry.ex", fn file ->
        assert file =~ "defmodule FlowyAppWeb.Telemetry do"
        assert file =~ "{:telemetry_poller, measurements: periodic_measurements()"
        assert file =~ "defp periodic_measurements do"
        assert file =~ "# {FlowyAppWeb, :count_users, []}"
        assert file =~ "def metrics do"
        assert file =~ "summary(\"phoenix.endpoint.stop.duration\","
        assert file =~ "summary(\"phoenix.router_dispatch.stop.duration\","
        assert file =~ "# Database Metrics"
        assert file =~ "summary(\"flowy_app.repo.query.total_time\","
      end)

      # Mailer
      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "{:swoosh, \"~> 1.3\"}"
        assert file =~ "{:finch, \"~> 0.13\"}"
      end)

      assert_file("flowy_app/lib/flowy_app/application.ex", fn file ->
        assert file =~ "{Finch, name: FlowyApp.Finch}"
      end)

      assert_file("flowy_app/lib/flowy_app/mailer.ex", fn file ->
        assert file =~ "defmodule FlowyApp.Mailer do"
        assert file =~ "use Swoosh.Mailer, otp_app: :flowy_app"
      end)

      assert_file("flowy_app/config/config.exs", fn file ->
        assert file =~ "config :flowy_app, FlowyApp.Mailer, adapter: Swoosh.Adapters.Local"
      end)

      assert_file("flowy_app/config/test.exs", fn file ->
        assert file =~ "config :swoosh"
        assert file =~ "config :flowy_app, FlowyApp.Mailer, adapter: Swoosh.Adapters.Test"
      end)

      assert_file("flowy_app/config/dev.exs", fn file ->
        assert file =~ "config :swoosh"
      end)

      assert_file("flowy_app/config/prod.exs", fn file ->
        assert file =~
                 "config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: FlowyApp.Finch"
      end)

      # Install dependencies?
      assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd flowy_app"
      assert msg =~ "$ mix deps.get"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Flowy app" <> _]}

      # Gettext
      assert_file("flowy_app/lib/flowy_app_web/gettext.ex", ~r"defmodule FlowyAppWeb.Gettext")
      assert File.exists?("flowy_app/priv/gettext/errors.pot")
      assert File.exists?("flowy_app/priv/gettext/en/LC_MESSAGES/errors.po")
    end)
  end

  test "new without defaults" do
    in_tmp("new without defaults", fn ->
      Mix.Tasks.Flowy.New.run([
        @app_name,
        "--no-html",
        "--no-assets",
        "--no-ecto",
        "--no-gettext",
        "--no-dashboard",
        "--no-mailer"
      ])

      # No assets
      assert_file("flowy_app/.gitignore", fn file ->
        refute file =~ "/priv/static/assets/"
        assert file =~ ~r/\n$/
      end)

      refute File.exists?("flowy_app/priv/static/images/logo.png")

      assert_file("flowy_app/config/dev.exs", ~r/watchers: \[\]/)

      # No assets & No HTML
      refute_file("flowy_app/priv/static/assets/app.css")
      refute_file("flowy_app/priv/static/assets/app.js")

      # No Ecto
      config = ~r/config :flowy_app, FlowyApp.Repo,/
      refute File.exists?("flowy_app/lib/flowy_app/repo.ex")

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        refute file =~ "plug Phoenix.Ecto.CheckRepoStatus, otp_app: :flowy_app"
      end)

      assert_file("flowy_app/lib/flowy_app_web/telemetry.ex", fn file ->
        refute file =~ "# Database Metrics"
        refute file =~ "summary(\"flowy_app.repo.query.total_time\","
      end)

      assert_file("flowy_app/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:open_api_spex, :phoenix]"
        assert file =~ "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\"]"
        refute file =~ "subdirectories:"
      end)

      assert_file("flowy_app/mix.exs", &refute(&1 =~ ~r":phoenix_ecto"))

      assert_file("flowy_app/config/config.exs", fn file ->
        refute file =~ "config :esbuild"
        refute file =~ "config :flowy_app, :generators"
        refute file =~ "ecto_repos:"
      end)

      assert_file("flowy_app/config/dev.exs", fn file ->
        refute file =~ config
        assert file =~ "config :phoenix, :plug_init_mode, :runtime"
      end)

      assert_file("flowy_app/config/test.exs", &refute(&1 =~ config))
      assert_file("flowy_app/config/runtime.exs", &refute(&1 =~ config))
      assert_file("flowy_app/lib/flowy_app_web.ex", &refute(&1 =~ ~r"alias FlowyApp.Repo"))

      # No gettext
      refute_file("flowy_app/lib/flowy_app_web/gettext.ex")
      refute_file("flowy_app/priv/gettext/en/LC_MESSAGES/errors.po")
      refute_file("flowy_app/priv/gettext/errors.pot")
      assert_file("flowy_app/mix.exs", &refute(&1 =~ ~r":gettext"))
      assert_file("flowy_app/lib/flowy_app_web.ex", &refute(&1 =~ ~r"import AmsMockWeb.Gettext"))
      assert_file("flowy_app/config/dev.exs", &refute(&1 =~ ~r"gettext"))

      # No HTML
      assert File.exists?("flowy_app/test/flowy_app_web/controllers")

      assert File.exists?("flowy_app/lib/flowy_app_web/controllers")

      refute File.exists?("flowy_app/test/web/controllers/pager_controller_test.exs")
      refute File.exists?("flowy_app/lib/flowy_app_web/controllers/page_controller.ex")
      refute File.exists?("flowy_app/lib/flowy_app_web/controllers/page_html")
      refute File.exists?("flowy_app/lib/flowy_app_web/controllers/error_html.ex")
      refute File.exists?("flowy_app/lib/flowy_app_web/components")

      assert_file("flowy_app/mix.exs", &refute(&1 =~ ~r":phoenix_html"))
      assert_file("flowy_app/mix.exs", &refute(&1 =~ ~r":phoenix_live_reload"))

      assert_file("flowy_app/lib/flowy_app_web.ex", fn file ->
        refute file =~ "html_helpers"
        refute file =~ "Phoenix.HTML"
        refute file =~ "Phoenix.LiveView"
      end)

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        refute file =~ ~r"Phoenix.LiveReloader"
        refute file =~ ~r"Phoenix.LiveReloader.Socket"
      end)

      refute_file("flowy_app/lib/flowy_app_web/controllers/error_html.ex")
      assert_file("flowy_app/lib/flowy_app_web/controllers/error_json.ex")
      assert_file("flowy_app/lib/flowy_app_web/router.ex", &refute(&1 =~ ~r"pipeline :browser"))

      # No Dashboard
      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("flowy_app/lib/flowy_app_web/router.ex", fn file ->
        refute file =~ "live_dashboard"
        refute file =~ "import Phoenix.LiveDashboard.Router"
      end)

      # No mailer or emails
      assert_file("flowy_app/mix.exs", fn file ->
        refute file =~ "{:swoosh, \"~> 1.3\"}"
        refute file =~ "{:finch, \"~> 0.13\"}"
      end)

      assert_file("flowy_app/lib/flowy_app/application.ex", fn file ->
        refute file =~ "{Finch, name: FlowyApp.Finch"
      end)

      refute File.exists?("flowy_app/lib/flowy_app/mailer.ex")

      assert_file("flowy_app/config/config.exs", fn file ->
        refute file =~ "config :swoosh"
        refute file =~ "config :flowy_app, FlowyApp.Mailer, adapter: Swoosh.Adapters.Local"
      end)

      assert_file("flowy_app/config/test.exs", fn file ->
        refute file =~ "config :swoosh"
        refute file =~ "config :flowy_app, FlowyApp.Mailer, adapter: Swoosh.Adapters.Test"
      end)

      assert_file("flowy_app/config/dev.exs", fn file ->
        refute file =~ "config :swoosh"
      end)

      assert_file("flowy_app/config/prod.exs", fn file ->
        refute file =~ "config :swoosh"
      end)
    end)
  end

  test "new with --no-dashboard" do
    in_tmp("new with no_dashboard", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-dashboard"])

      assert_file("flowy_app/mix.exs", &refute(&1 =~ ~r":phoenix_live_dashboard"))

      assert_file("flowy_app/lib/flowy_app_web/components/layouts/app.html.heex", fn file ->
        refute file =~ ~s|LiveDashboard|
      end)

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule FlowyAppWeb.Endpoint|
        assert file =~ ~s|  socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)
    end)
  end

  test "new with --no-dashboard and --no-live" do
    in_tmp("new with no_dashboard and no_live", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-dashboard", "--no-live"])

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule FlowyAppWeb.Endpoint|
        assert file =~ ~s|# socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)
    end)
  end

  test "new with --no-html" do
    in_tmp("new with no_html", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-html"])

      assert_file("flowy_app/mix.exs", fn file ->
        refute file =~ ~s|:phoenix_live_view|
        refute file =~ ~s|:phoenix_html|
        assert file =~ ~s|:phoenix_live_dashboard|
      end)

      assert_file("flowy_app/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:open_api_spex, :ecto, :ecto_sql, :phoenix]"
        assert file =~ "subdirectories: [\"priv/*/migrations\"]"

        assert file =~
                 "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\", \"priv/*/seeds.exs\"]"

        refute file =~ "plugins:"
      end)

      assert_file("flowy_app/lib/flowy_app_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule FlowyAppWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("flowy_app/lib/flowy_app_web.ex", fn file ->
        refute file =~ ~s|Phoenix.HTML|
        refute file =~ ~s|Phoenix.LiveView|
      end)

      assert_file("flowy_app/lib/flowy_app_web/router.ex", fn file ->
        refute file =~ ~s|pipeline :browser|
        assert file =~ ~s|pipe_through [:fetch_session, :protect_from_forgery]|
      end)
    end)
  end

  test "new with --no-assets" do
    in_tmp("new no_assets", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-assets"])

      assert_file("flowy_app/.gitignore", fn file ->
        refute file =~ "/priv/static/assets/"
      end)

      assert_file("flowy_app/.gitignore")
      assert_file("flowy_app/docs/guides/directory_structure.md")
      assert_file("flowy_app/.github/dependabot.yml")
      assert_file("flowy_app/.github/workflows/test.yml")
      assert_file("flowy_app/.gitignore", ~r/\n$/)
      assert_file("flowy_app/priv/static/assets/app.css")
      assert_file("flowy_app/priv/static/assets/app.js")
      assert_file("flowy_app/priv/static/favicon.ico")

      assert_file("flowy_app/config/config.exs", fn file ->
        refute file =~ "config :esbuild"
      end)

      assert_file("flowy_app/config/prod.exs", fn file ->
        refute file =~ "config :flowy_app, FlowyAppWeb.Endpoint, cache_static_manifest:"
      end)
    end)
  end

  test "new with --no-ecto" do
    in_tmp("new with no_ecto", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-ecto"])

      assert_file("flowy_app/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:open_api_spex, :phoenix]"
        assert file =~ "plugins: [Phoenix.LiveView.HTMLFormatter]"
        assert file =~ "inputs: [\"*.{heex,ex,exs}\", \"{config,lib,test}/**/*.{heex,ex,exs}\"]"
        refute file =~ "subdirectories:"
      end)
    end)
  end

  test "new with binary_id" do
    in_tmp("new with binary_id", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--binary-id"])
      assert_file("flowy_app/config/config.exs", ~r/generators: \[.*binary_id: true\.*]/)
    end)
  end

  test "new with uppercase" do
    in_tmp("new with uppercase", fn ->
      Mix.Tasks.Flowy.New.run(["flowy_app"])

      assert_file("flowy_app/README.md")

      assert_file("flowy_app/mix.exs", fn file ->
        assert file =~ "app: :flowy_app"
      end)

      assert_file("flowy_app/config/dev.exs", fn file ->
        assert file =~ ~r/config :flowy_app, FlowyApp.Repo,/
        assert file =~ "database: \"flowy_app_dev\""
      end)
    end)
  end

  test "new with path, app and module" do
    in_tmp("new with path, app and module", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path, "--app", @app_name, "--module", "PhoteuxBlog"])

      assert_file("custom_path/.gitignore")
      assert_file("custom_path/.gitignore", ~r/\n$/)
      assert_file("custom_path/mix.exs", ~r/app: :flowy_app/)
      assert_file("custom_path/lib/flowy_app_web/endpoint.ex", ~r/app: :flowy_app/)
      assert_file("custom_path/config/config.exs", ~r/namespace: PhoteuxBlog/)
    end)
  end

  test "new inside umbrella" do
    in_tmp("new inside umbrella", fn ->
      File.write!("mix.exs", MixHelper.umbrella_mixfile_contents())
      File.mkdir!("apps")

      File.cd!("apps", fn ->
        Mix.Tasks.Flowy.New.run([@app_name])

        assert_file("flowy_app/mix.exs", fn file ->
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end)

        refute_file("flowy_app/config/config.exs")
      end)

      assert_file("config/config.exs", fn file ->
        assert file =~ "FlowyAppWeb.Endpoint"
        assert file =~ ~s[cd: Path.expand("../apps/flowy_app/assets", __DIR__),]
      end)

      assert_file("config/config.exs", "FlowyAppWeb.Endpoint")
    end)
  end

  test "new with --no-install" do
    in_tmp("new with no install", fn ->
      Mix.Tasks.Flowy.New.run([@app_name, "--no-install"])

      # Does not prompt to install dependencies
      refute_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd flowy_app"
      assert msg =~ "$ mix deps.get"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Flowy app" <> _]}
    end)
  end

  test "new defaults to pg adapter" do
    in_tmp("new defaults to pg adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path])

      assert_file("custom_path/mix.exs", ":postgrex")

      assert_file("custom_path/config/dev.exs", [
        ~r/username: System.get_env(\"DBUSER\") || \"postgres\"/,
        ~r/password: System.get_env(\"DBPASSWORD\") || \"postgres\"/,
        ~r/hostname: System.get_env(\"DBHOST\") || \"localhost\"/
      ])

      assert_file("custom_path/config/test.exs", [
        ~r/username: System.get_env(\"DBUSER\") || \"postgres\"/,
        ~r/password: System.get_env(\"DBPASSWORD\") || \"postgres\"/,
        ~r/hostname: System.get_env(\"DBHOST\") || \"localhost\"/
      ])

      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])
      assert_file("custom_path/lib/custom_path/repo.ex", "Ecto.Adapters.Postgres")

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with mysql adapter" do
    in_tmp("new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path, "--database", "mysql"])

      assert_file("custom_path/mix.exs", ":myxql")
      assert_file("custom_path/config/dev.exs", [~r/username: System.get_env(\"DBUSER\") || \"root\"/, ~r/password: System.get_env(\"DBPASSWORD\") || \"\"/])
      assert_file("custom_path/config/test.exs", [~r/username: System.get_env(\"DBUSER\") || \"root\"/, ~r/password: System.get_env(\"DBPASSWORD\") || \"\"/])
      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])
      assert_file("custom_path/lib/custom_path/repo.ex", "Ecto.Adapters.MyXQL")

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with sqlite3 adapter" do
    in_tmp("new with sqlite3 adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path, "--database", "sqlite3"])

      assert_file("custom_path/mix.exs", ":ecto_sqlite3")
      assert_file("custom_path/config/dev.exs", [~r/database: .*_dev.db/])
      assert_file("custom_path/config/test.exs", [~r/database: .*_test.db/])
      assert_file("custom_path/config/runtime.exs", [~r/database: database_path/])
      assert_file("custom_path/lib/custom_path/repo.ex", "Ecto.Adapters.SQLite3")

      assert_file("custom_path/lib/custom_path/application.ex", fn file ->
        assert file =~ "{Ecto.Migrator"
        assert file =~ "repos: Application.fetch_env!(:custom_path, :ecto_repos)"
        assert file =~ "skip: skip_migrations?()"

        assert file =~ "defp skip_migrations?() do"
        assert file =~ ~s/System.get_env("RELEASE_NAME") != nil/
      end)

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )

      assert_file("custom_path/.gitignore", "*.db")
      assert_file("custom_path/.gitignore", "*.db-*")
    end)
  end

  test "new with mssql adapter" do
    in_tmp("new with mssql adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path, "--database", "mssql"])

      assert_file("custom_path/mix.exs", ":tds")

      assert_file("custom_path/config/dev.exs", [
        ~r/username: System.get_env(\"DBUSER\") || \"sa\"/,
        ~r/password: System.get_env(\"DBPASSWORD\") || \"some!Password\"/
      ])

      assert_file("custom_path/config/test.exs", [
        ~r/username: System.get_env(\"DBUSER\") || \"sa\"/,
        ~r/password: System.get_env(\"DBPASSWORD\") || \"some!Password\"/
      ])

      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])
      assert_file("custom_path/lib/custom_path/repo.ex", "Ecto.Adapters.Tds")

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with invalid database adapter" do
    in_tmp("new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")

      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Flowy.New.run([project_path, "--database", "invalid"])
      end
    end)
  end

  test "new with bandit web adapter" do
    in_tmp("new with bandit web adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Flowy.New.run([project_path, "--adapter", "bandit"])
      assert_file("custom_path/mix.exs", ":bandit")

      assert_file("custom_path/config/config.exs", "adapter: Bandit.PhoenixAdapter")
    end)
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Flowy.New.run(["007invalid"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Flowy.New.run(["valid", "--app", "007invalid"])
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Flowy.New.run(["valid", "--module", "not.valid"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Flowy.New.run(["string"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Flowy.New.run(["valid", "--app", "mix"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Flowy.New.run(["valid", "--module", "String"])
    end
  end

  test "invalid options" do
    assert_raise OptionParser.ParseError, fn ->
      Mix.Tasks.Flowy.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp("new without args", fn ->
      assert capture_io(fn -> Mix.Tasks.Flowy.New.run([]) end) =~
               "Creates a new Flowy project."
    end)
  end
end
