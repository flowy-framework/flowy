defmodule Mix.Flowy.Core do
  @moduledoc """
  Generates a Flowy core module.
  """

  @type t :: %__MODULE__{
          base_module: atom,
          module: atom,
          alias: atom,
          file: String.t(),
          test_file: String.t(),
          schema: map()
        }

  defstruct base_module: nil,
            module: nil,
            alias: nil,
            file: nil,
            test_file: nil,
            schema: nil

  @doc """
  Builds a schema struct from the given arguments.
  """
  @spec new(
          schema_name :: String.t(),
          schema_plural :: String.t(),
          cli_attrs :: list,
          opts :: Keyword.t()
        ) :: t
  def new(schema_name, schema_plural, cli_attrs, opts) do
    schema = Mix.Phoenix.Schema.new("Schemas.#{schema_name}", schema_plural, cli_attrs, opts)

    basename = Phoenix.Naming.underscore(schema.plural)
    ctx_app = opts[:context_app] || Mix.Phoenix.context_app()
    # otp_app = Mix.Phoenix.otp_app()
    # opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Phoenix.context_base(ctx_app)

    %__MODULE__{
      base_module: base,
      module: Module.concat([base, "Core", "#{schema.human_plural}"]),
      alias: schema.human_plural |> Module.concat(nil),
      file: Mix.Flowy.lib_path(:core, schema.context_app, basename <> ".ex"),
      test_file: Mix.Flowy.test_path(:core, schema.context_app, basename <> "_test.exs"),
      schema: schema
    }
  end
end
