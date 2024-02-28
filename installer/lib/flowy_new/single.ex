defmodule Flowy.New.Single do
  @moduledoc false
  use Flowy.New.Generator
  alias Flowy.New.{Project}

  template(:new, [
    {:config, :project,
     "phx_single/config/config.exs": "config/config.exs",
     "phx_single/config/dev.exs": "config/dev.exs",
     "phx_single/config/prod.exs": "config/prod.exs",
     "phx_single/config/runtime.exs": "config/runtime.exs",
     "phx_single/config/test.exs": "config/test.exs"},
    {:eex, :web,
     "phx_single/lib/app_name/application.ex": "lib/:app/application.ex",
     "phx_single/lib/app_name/release.ex": "lib/:app/release.ex",
     "phx_single/lib/app_name.ex": "lib/:app.ex",
     "phx_single/lib/app_name/core/users.ex": "lib/:app/core/users.ex",
     "phx_single/lib/app_name/queries/helper.ex": "lib/:app/queries/helper.ex",
     "phx_single/lib/app_name/schemas/user.ex": "lib/:app/schemas/user.ex",
     "phx_web/api_spec.ex": "lib/:lib_web_name/api_spec.ex",
     "phx_web/endpoint.ex": "lib/:lib_web_name/endpoint.ex",
     "phx_web/router.ex": "lib/:lib_web_name/router.ex",
     "phx_web/telemetry.ex": "lib/:lib_web_name/telemetry.ex",
     "phx_single/lib/app_name_web.ex": "lib/:lib_web_name.ex",
     "phx_single/mix.exs": "mix.exs",
     "phx_single/README.md": "README.md",
     "phx_single/formatter.exs": ".formatter.exs",
     "phx_single/gitignore": ".gitignore",
     "phx_single/doctor.exs": ".doctor.exs",
     "phx_single/dockerignore": ".dockerignore",
     "phx_single/credo.exs": ".credo.exs",
     "phx_single/Dockerfile": "Dockerfile",
     "phx_single/entrypoint.sh": "entrypoint.sh",
     "phx_single/renovate.json": "renovate.json",
     "phx_single/docs/guides/directory_structure.md": "docs/guides/directory_structure.md",
     "phx_single/github/dependabot.yml": ".github/dependabot.yml",
     "phx_single/github/workflows/test.yml": ".github/workflows/test.yml",
     "phx_test/support/conn_case.ex": "test/support/conn_case.ex",
     "phx_test/support/fixtures/users_fixtures.ex": "test/support/fixtures/users_fixtures.ex",
     "phx_single/test/test_helper.exs": "test/test_helper.exs",
     "phx_test/controllers/error_json_test.exs":
       "test/:lib_web_name/controllers/error_json_test.exs"},
    {:keep, :web,
     "phx_web/controllers": "lib/:lib_web_name/controllers",
     "phx_test/controllers": "test/:lib_web_name/controllers"}
  ])

  template(:gettext, [
    {:eex, :web,
     "phx_gettext/gettext.ex": "lib/:lib_web_name/gettext.ex",
     "phx_gettext/en/LC_MESSAGES/errors.po": "priv/gettext/en/LC_MESSAGES/errors.po",
     "phx_gettext/errors.pot": "priv/gettext/errors.pot"}
  ])

  template(:html, [
    {:eex, :web,
     "phx_web/live/home_live.ex": "lib/:lib_web_name/live/home_live.ex",
     "phx_web/live/home_live.html.heex": "lib/:lib_web_name/live/home_live.html.heex",
     "phx_web/components/layouts/root.html.heex":
       "lib/:lib_web_name/components/layouts/root.html.heex",
     "phx_web/components/layouts/app.html.heex":
       "lib/:lib_web_name/components/layouts/app.html.heex",
     "phx_web/components/layouts/live.html.heex":
       "lib/:lib_web_name/components/layouts/live.html.heex",
     "phx_web/components/layouts/unauthenticated.html.heex":
       "lib/:lib_web_name/components/layouts/unauthenticated.html.heex",
     "phx_web/components/layouts.ex": "lib/:lib_web_name/components/layouts.ex"},
     {:text, :web, "phx_assets/logo.png": "priv/static/images/logo.png"},
     {:text, :web, "phx_assets/default-user-avatar.jpg": "priv/static/images/default-user-avatar.jpg"},
    {:zip, :web, "phx_assets/fonts/fonts.zip": "priv/static/fonts/fonts"}
  ])

  template(:ecto, [
    {:eex, :app,
     "phx_ecto/repo.ex": "lib/:app/repo.ex",
     "phx_ecto/formatter.exs": "priv/repo/migrations/.formatter.exs",
     "phx_ecto/20230906161135_add_oban_jobs_table.exs": "priv/repo/migrations/20230906161135_add_oban_jobs_table.exs",
     "phx_ecto/20230907161135_create_users_auth_tables.exs": "priv/repo/migrations/20230907161135_create_users_auth_tables.exs",
     "phx_ecto/seeds.exs": "priv/repo/seeds.exs",
     "phx_ecto/data_case.ex": "test/support/data_case.ex"},
    {:keep, :app, "phx_ecto/priv/repo/migrations": "priv/repo/migrations"}
  ])

  template(:css, [
    {:eex, :web,
     "phx_assets/app.css": "assets/css/app.css",
     "phx_assets/tailwind.config.js": "assets/tailwind.config.js",
     "phx_assets/package.json": "assets/package.json"}
  ])

  template(:js, [
    {:eex, :web,
     "phx_assets/app.js": "assets/js/app.js"}
  ])

  template(:no_js, [
    {:text, :web, "phx_static/app.js": "priv/static/assets/app.js"}
  ])

  template(:no_css, [
    {:text, :web,
     "phx_static/app.css": "priv/static/assets/app.css",
     "phx_static/home.css": "priv/static/assets/home.css"}
  ])

  template(:static, [
    {:text, :web,
     "phx_static/robots.txt": "priv/static/robots.txt",
     "phx_static/favicon.ico": "priv/static/favicon.ico"}
  ])

  template(:mailer, [
    {:eex, :app, "phx_mailer/lib/app_name/mailer.ex": "lib/:app/mailer.ex"}
  ])

  def prepare_project(%Project{app: app, base_path: base_path} = project) when not is_nil(app) do
    if in_umbrella?(base_path) do
      %Project{project | in_umbrella?: true, project_path: Path.dirname(Path.dirname(base_path))}
    else
      %Project{project | in_umbrella?: false, project_path: base_path}
    end
    |> put_app()
    |> put_root_app()
    |> put_web_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %Project{project | app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %Project{
      project
      | root_app: app,
        root_mod: Module.concat([opts[:module] || Macro.camelize(app)])
    }
  end

  defp put_web_app(%Project{app: app} = project) do
    %Project{
      project
      | web_app: app,
        lib_web_name: "#{app}_web",
        web_namespace: Module.concat(["#{project.root_mod}Web"]),
        web_path: project.base_path
    }
  end

  def generate(%Project{} = project) do
    copy_from(project, __MODULE__, :new)

    if Project.ecto?(project), do: gen_ecto(project)
    if Project.html?(project), do: gen_html(project)
    if Project.mailer?(project), do: gen_mailer(project)
    if Project.gettext?(project), do: gen_gettext(project)

    gen_assets(project)
    project
  end

  def gen_html(project) do
    copy_from(project, __MODULE__, :html)
  end

  def gen_gettext(project) do
    copy_from(project, __MODULE__, :gettext)
  end

  def gen_ecto(project) do
    copy_from(project, __MODULE__, :ecto)
    gen_ecto_config(project)
  end

  def gen_assets(%Project{} = project) do
    javascript? = Project.javascript?(project)
    css? = Project.css?(project)
    html? = Project.html?(project)

    copy_from(project, __MODULE__, :static)

    if html? or javascript? do
      command = if javascript?, do: :js, else: :no_js
      copy_from(project, __MODULE__, command)
    end

    if html? or css? do
      command = if css?, do: :css, else: :no_css
      copy_from(project, __MODULE__, command)
    end
  end

  def gen_mailer(%Project{} = project) do
    copy_from(project, __MODULE__, :mailer)
  end
end
