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
    Mix.Flowy.copy_from(paths, "priv/templates/flowy.gen.core", binding, files)

    core
  end

  defp run_schema(args), do: Mix.Tasks.Flowy.Gen.Schema.run(args)
  defp run_query(args), do: Mix.Tasks.Flowy.Gen.Query.run(args)

  defp run_core(args) do
    core = build(args, [])
    paths = Mix.Flowy.generator_paths() ++ [:flowy]

    core
    |> copy_new_files(paths, core: core, schema: core.schema)
  end

  @doc false
  def prompt_for_code_injection(%Core{generate?: false}), do: :ok

  def prompt_for_code_injection(%Core{} = core) do
    if Core.pre_existing?(core) && !merge_with_existing_core?(core) do
      System.halt()
    end
  end

  defp merge_with_existing_core?(%Core{} = core) do
    Keyword.get_lazy(core.opts, :merge_with_existing_core, fn ->
      function_count = Core.function_count(core)
      file_count = Core.file_count(core)

      Mix.shell().info("""
      You are generating into an existing core.

      The #{inspect(core.module)} core currently has #{singularize(function_count, "functions")} and \
      #{singularize(file_count, "files")} in its directory.

        * It's OK to have multiple resources in the same core as \
      long as they are closely related. But if a core grows too \
      large, consider breaking it apart

        * If they are not closely related, another context probably works better

      The fact two entities are related in the database does not mean they belong \
      to the same context.

      If you are not sure, prefer creating a new context over adding to the existing one.
      """)

      Mix.shell().yes?("Would you like to proceed?")
    end)
  end

  defp singularize(1, plural), do: "1 " <> String.trim_trailing(plural, "s")
  defp singularize(amount, plural), do: "#{amount} #{plural}"
end
