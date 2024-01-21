defmodule Mix.Flowy.Query do
  @moduledoc """
  Generates a Flowy query module.
  """
  @type t :: %__MODULE__{
          base_module: atom,
          module: atom,
          opts: Keyword.t(),
          alias: atom,
          file: String.t(),
          test_file: String.t(),
          fixture_file: String.t(),
          fixture_setup_file: String.t(),
          plural: String.t(),
          singular: String.t(),
          human_singular: String.t(),
          human_plural: String.t(),
          schema: Mix.Flowy.Schema.t(),
          context_app: atom,
          generate?: boolean
        }

  defstruct base_module: nil,
            module: nil,
            opts: [],
            alias: nil,
            file: nil,
            test_file: nil,
            fixture_file: nil,
            fixture_setup_file: nil,
            plural: nil,
            singular: nil,
            human_singular: nil,
            human_plural: nil,
            schema: nil,
            context_app: nil,
            generate?: false

  @doc """
  Builds a query struct from the given arguments.
  """
  @spec new(schema :: Mix.Flowy.Schema.t(), opts :: keyword()) :: t
  def new(schema, opts) do
    basename = Phoenix.Naming.underscore(schema.schema_name)
    # otp_app = Mix.Flowy.otp_app()
    # opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Flowy.context_base(schema.context_app)
    generate? = Keyword.get(opts, :query, true)
    module_name = schema.schema_name <> "Query"
    module = Module.concat(module_name, nil)

    %__MODULE__{
      base_module: base,
      module: Module.concat([base, "Queries", module_name]),
      opts: schema.opts,
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: Mix.Flowy.lib_path(:queries, schema.context_app, basename <> "_query.ex"),
      test_file: Mix.Flowy.test_path(:queries, schema.context_app, basename <> "_query_test.exs"),
      fixture_file:
        Mix.Flowy.context_test_path(
          schema.context_app,
          "support/fixtures/" <> basename <> "_fixtures.ex"
        ),
      fixture_setup_file: Mix.Flowy.context_test_path(schema.context_app, "support/setups.ex"),
      plural: schema.plural,
      schema: schema,
      context_app: schema.context_app,
      generate?: generate?
    }
  end

  @doc """
  Check if the query module already exists.
  """
  @spec pre_existing?(t()) :: boolean()
  def pre_existing?(%__MODULE__{file: file}), do: File.exists?(file)

  @doc """
  Check if the query test module already exists.
  """
  @spec pre_existing_tests?(t()) :: boolean()
  def pre_existing_tests?(%__MODULE__{test_file: file}), do: File.exists?(file)
end
