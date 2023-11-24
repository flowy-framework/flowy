defmodule Mix.Tasks.Flowy.Gen.Query do
  @shortdoc "Generates a Query module"

  @moduledoc """
  Generates Flowy components.

      $ mix flowy.gen.query User users name:string age:integer
  """

  use Mix.Task
  alias Mix.Flowy.Query

  @doc false
  def run(args) do
    query = build(args, [])
    paths = Mix.Flowy.generator_paths() ++ [:flowy]

    query
    |> copy_new_files(paths, query: query, schema: query.schema)
    |> print_shell_instructions()
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {schema_name, plural, attrs, opts} = Mix.Flowy.pre_build(args, parent_opts, help)

    Query.new(schema_name, plural, attrs, opts)
  end

  defp print_shell_instructions(%{schema: schema} = query) do
    Mix.shell().info("""

    Add the generated fixture to your #{query.fixture_setup_file} file:

      alias #{query.base_module}.Tests.Fixtures.#{schema.human_singular}Fixtures

      def setup_#{schema.singular}(context) do
        #{schema.singular} = #{inspect(schema.alias)}Fixtures.#{schema.singular}_fixture()

        context
        |> add_to_context(%{#{schema.singular}: #{schema.singular}})
      end
    """)
  end

  @doc false
  def files_to_be_generated(%Query{} = query) do
    [
      {:eex, "query.ex", query.file},
      {:eex, "query_test.ex", query.test_file},
      {:eex, "query_fixture.ex", query.fixture_file},
      {:eex, "setup_fixtures.ex", query.fixture_setup_file}
    ]
  end

  @doc false
  def copy_new_files(
        %Query{} = query,
        paths,
        binding
      ) do
    files = files_to_be_generated(query)
    Mix.Flowy.copy_from(paths, "priv/templates/flowy.gen.query", binding, files)

    query
  end
end
