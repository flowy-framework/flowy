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
          schema: Mix.Phoenix.Schema.t(),
          context_app: atom
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
            context_app: nil

  @doc """
  Builds a query struct from the given arguments.
  """
  @spec new(
          schema_name :: String.t(),
          schema_plural :: String.t(),
          cli_attrs :: list,
          opts :: Keyword.t()
        ) :: t
  def new(schema_name, schema_plural, cli_attrs, opts) do
    schema = Mix.Phoenix.Schema.new("Schemas.#{schema_name}", schema_plural, cli_attrs, opts)

    basename = Phoenix.Naming.underscore(schema.singular)
    ctx_app = opts[:context_app] || Mix.Phoenix.context_app()
    # otp_app = Mix.Phoenix.otp_app()
    # opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Phoenix.context_base(ctx_app)

    %__MODULE__{
      base_module: base,
      module: Module.concat([base, "Queries", "#{schema.human_singular}Query"]),
      opts: schema.opts,
      alias: "#{schema.alias}Query" |> Module.concat(nil),
      file: Mix.Flowy.lib_path(:queries, schema.context_app, basename <> "_query.ex"),
      test_file: Mix.Flowy.test_path(:queries, schema.context_app, basename <> "_query_test.exs"),
      fixture_file:
        Mix.Flowy.context_test_path(
          schema.context_app,
          "support/fixtures/" <> basename <> "_fixtures.ex"
        ),
      fixture_setup_file: Mix.Flowy.context_test_path(schema.context_app, "support/setup.ex"),
      plural: schema.plural,
      schema: schema,
      context_app: schema.context_app
    }
  end
end
