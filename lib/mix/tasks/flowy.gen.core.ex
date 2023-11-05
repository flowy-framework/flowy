defmodule Mix.Tasks.Flowy.Gen.Core do
  @shortdoc "Generates a Core module"

  @moduledoc """
  Generates Flowy components.

      $ mix flowy.gen.core User users name:string age:integer

  The first argument is the schema module followed by its plural
  name (used as the table name).

  The core is an Elixir module that serves as an API boundary for
  the given resource. A core module often holds many related resources.
  Therefore, if the core module already exists, it will be augmented with
  functions for the given resource.

  The schema is responsible for mapping the database fields into an
  Elixir struct.

  Overall, this generator will add the following files to `lib/your_app`:

    * a core module in `accounts.ex`, serving as the API boundary
    * a query in `queries/user_query.ex`, serving as the Repo boundary
    * a schema in `schemas/user.ex`, with a `users` table

  A migration file for the repository and test files for the context
  will also be generated.
  """

  use Mix.Task
  alias Mix.Flowy.Core

  @doc false
  def run(args) do
    run_schema(args)
    run_query(args)
    run_core(args)
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {schema_name, plural, attrs, opts} = Mix.Flowy.pre_build(args, parent_opts, help)

    Core.new(schema_name, plural, attrs, opts)
  end

  @doc false
  def files_to_be_generated(%Core{} = core) do
    [
      {:eex, "core.ex", core.file},
      {:eex, "core_test.ex", core.test_file}
    ]
  end

  @doc false
  def copy_new_files(
        %Core{} = core,
        paths,
        binding
      ) do
    files = files_to_be_generated(core)
    Mix.Phoenix.copy_from(paths, "priv/templates/flowy.gen.core", binding, files)

    core
  end

  defp run_schema(args), do: Mix.Tasks.Flowy.Gen.Schema.run(args)
  defp run_query(args), do: Mix.Tasks.Flowy.Gen.Query.run(args)

  defp run_core(args) do
    core = build(args, [])
    paths = Mix.Phoenix.generator_paths() ++ [:flowy]

    core
    |> copy_new_files(paths, core: core, schema: core.schema)
  end
end
