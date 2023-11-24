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
  alias Mix.Flowy.{Core, Schema}
  alias Mix.Tasks.Flowy.Gen

  @switches [
    binary_id: :boolean,
    table: :string,
    web: :string,
    schema: :boolean,
    context: :boolean,
    context_app: :string,
    merge_with_existing_context: :boolean,
    prefix: :string,
    live: :boolean
  ]

  @default_opts [schema: true, core: true, query: true]

  @doc false
  def run(args) do
    # run_query(args)
    run_core(args)
  end

  @doc false
  def build(args, help \\ __MODULE__) do
    {opts, parsed, _} = parse_opts(args)
    [context_name, schema_name, plural | schema_args] = validate_args!(parsed, help)
    schema = Gen.Schema.build([schema_name, plural | schema_args], opts, help)
    core = Core.new(context_name, schema, opts)
    {core, schema}
  end

  defp parse_opts(args) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

    merged_opts =
      @default_opts
      |> Keyword.merge(opts)
      |> put_context_app(opts[:context_app])

    {merged_opts, parsed, invalid}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  defp validate_args!([core, schema, _plural | _] = args, help) do
    cond do
      not Core.valid?(core) ->
        help.raise_with_help("Expected the core, #{inspect(core)}, to be a valid module name")

      not Schema.valid?(schema) ->
        help.raise_with_help("Expected the schema, #{inspect(schema)}, to be a valid module name")

      core == schema ->
        help.raise_with_help("The core and schema should have different names")

      core == Mix.Phoenix.base() ->
        help.raise_with_help(
          "Cannot generate context #{core} because it has the same name as the application"
        )

      schema == Mix.Phoenix.base() ->
        help.raise_with_help(
          "Cannot generate schema #{schema} because it has the same name as the application"
        )

      true ->
        args
    end
  end

  defp validate_args!(_, help) do
    help.raise_with_help("Invalid arguments")
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
        %Core{schema: schema, query: query} = core,
        paths,
        binding
      ) do
    if schema.generate?, do: Gen.Schema.copy_new_files(schema, paths, binding)
    if query.generate?, do: Gen.Query.copy_new_files(query, paths, binding)
    files = files_to_be_generated(core)
    Mix.Flowy.copy_from(paths, "priv/templates/flowy.gen.core", binding, files)

    core
  end

  defp run_core(args) do
    {core, schema} = build(args)
    binding = [core: core, schema: schema, query: core.query]
    paths = Mix.Flowy.generator_paths()

    prompt_for_conflicts(core)
    prompt_for_code_injection(core)

    core
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  @doc false
  def prompt_for_code_injection(%Core{generate?: false}), do: :ok

  def prompt_for_code_injection(%Core{} = core) do
    if Core.pre_existing?(core) && !merge_with_existing_core?(core) do
      System.halt()
    end
  end

  @doc false
  def print_shell_instructions(%Core{schema: schema, query: query}) do
    print_schema_shell_instructions(schema)
    print_query_shell_instructions(query)
  end

  defp print_schema_shell_instructions(%{generate?: true} = schema),
    do: Gen.Schema.print_shell_instructions(schema)

  defp print_schema_shell_instructions(%{generate?: false}), do: :ok

  defp print_query_shell_instructions(%{generate?: true} = query),
    do: Gen.Query.print_shell_instructions(query)

  defp print_query_shell_instructions(%{generate?: false}), do: :ok

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
