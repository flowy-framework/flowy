defmodule Mix.Tasks.Flowy.Gen.Json do
  @shortdoc "Generates core and controller for a JSON resource"

  @moduledoc """
  Generates controller, JSON view, and context for a JSON resource.

      mix flowy.gen.json Accounts User users name:string age:integer

  The first argument is the context module followed by the schema module
  and its plural name (used as the schema table name).

  The context is an Elixir module that serves as an API boundary for
  the given resource. A context often holds many related resources.
  Therefore, if the context already exists, it will be augmented with
  functions for the given resource.

  > Note: A resource may also be split
  > over distinct contexts (such as `Accounts.User` and `Payments.User`).

  The schema is responsible for mapping the database fields into an
  Elixir struct. It is followed by an optional list of attributes,
  with their respective names and types. See `mix phx.gen.schema`
  for more information on attributes.

  Overall, this generator will add the following files to `lib/`:

    * a core module in `lib/app/core/users.ex` for the accounts API
    * a schema in `lib/app/schemas/user.ex`, with an `users` table
    * a controller in `lib/app_web/controllers/api/user_controller.ex`
    * a JSON view collocated with the controller in `lib/app_web/controllers/user_json.ex`

  A migration file for the repository and test files for the context and
  controller features will also be generated.

  ## API Prefix

  By default, the prefix "/api" will be generated for API route paths.
  This can be customized via the `:api_prefix` generators configuration:

      config :your_app, :generators,
        api_prefix: "/api/i1"

  ## The context app

  The location of the web files (controllers, json views, etc) in an
  umbrella application will vary based on the `:context_app` config located
  in your applications `:generators` configuration. When set, the Phoenix
  generators will generate web files directly in your lib and test folders
  since the application is assumed to be isolated to web specific functionality.
  If `:context_app` is not set, the generators will place web related lib
  and test files in a `web/` directory since the application is assumed
  to be handling both web and domain specific functionality.
  Example configuration:

      config :my_app_web, :generators, context_app: :my_app

  Alternatively, the `--context-app` option may be supplied to the generator:

      mix flowy.gen.json Sales User users --context-app warehouse

  ## Customizing the context, schema, tables and migrations

  In some cases, you may wish to bootstrap JSON views, controllers,
  and controller tests, but leave internal implementation of the context
  or schema to yourself. You can use the `--no-context` and `--no-schema`
  flags for file generation control.

  You can also change the table name or configure the migrations to
  use binary ids for primary keys, see `mix phx.gen.schema` for more
  information.
  """

  use Mix.Task

  alias Mix.Flowy.Core
  alias Mix.Tasks.Flowy.Gen

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix flowy.gen.json must be invoked from within your *_web application root directory"
      )
    end

    {%{query: query} = core, schema} = Gen.Core.build(args)
    Gen.Core.prompt_for_code_injection(core)

    binding = [
      core: core,
      schema: schema,
      query: query,
      # core_components?: Code.ensure_loaded?(Module.concat(context.web_module, "CoreComponents")),
      gettext?: Code.ensure_loaded?(Module.concat(core.web_module, "Gettext"))
    ]

    paths = Mix.Flowy.generator_paths()

    prompt_for_conflicts(core)

    core
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(core) do
    core
    |> files_to_be_generated()
    |> Kernel.++(core_files(core))
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  defp core_files(%Core{generate?: true} = core) do
    Gen.Core.files_to_be_generated(core)
  end

  defp core_files(%Core{generate?: false}) do
    []
  end

  @doc false
  def files_to_be_generated(%Core{schema: schema, context_app: context_app}) do
    singular = schema.singular
    plural = schema.plural
    web = Mix.Flowy.web_path(context_app)
    test_prefix = Mix.Flowy.web_test_path(context_app)
    web_path = to_string(schema.web_path)
    controller_pre = Path.join([web, "controllers", "api", web_path])
    test_pre = Path.join([test_prefix, "controllers", "api", web_path])

    [
      {:eex, "controller.ex", Path.join([controller_pre, "#{singular}_controller.ex"])},
      {:eex, "json.ex", Path.join([controller_pre, "#{singular}_json.ex"])},
      {:eex, "api_spec.ex", Path.join([web, "api_specs", "#{plural}.ex"])},
      {:new_eex, "changeset_json.ex", Path.join([web, "controllers", "changeset_json.ex"])},
      {:eex, "controller_test.exs", Path.join([test_pre, "#{singular}_controller_test.exs"])},
      {:new_eex, "fallback_controller.ex",
       Path.join([web, "controllers", "fallback_controller.ex"])}
    ]
  end

  @doc false
  def copy_new_files(%Core{} = core, paths, binding) do
    files = files_to_be_generated(core)
    Mix.Flowy.copy_from(paths, "priv/templates/flowy.gen.json", binding, files)
    if core.generate?, do: Gen.Core.copy_new_files(core, paths, binding)

    core
  end

  @doc false
  def print_shell_instructions(%Core{schema: schema, context_app: ctx_app} = core) do
    if schema.web_namespace do
      Mix.shell().info("""

      Add the resource to your #{schema.web_namespace} :api scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          scope "/api/#{schema.web_path}", #{inspect(Module.concat(core.web_module, schema.web_namespace))}, as: :#{schema.web_path} do
            pipe_through :api
            ...
            resources "/#{schema.plural}", #{inspect(schema.alias)}Controller
          end
      """)
    else
      Mix.shell().info("""

      Add the resource to your :api scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          resources "/#{schema.plural}", #{inspect(schema.alias)}Controller, except: [:new, :edit]
      """)
    end

    if core.generate?, do: Gen.Core.print_shell_instructions(core)
  end
end
