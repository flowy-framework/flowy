defmodule Mix.Flowy.Core do
  @moduledoc """
  Generates a Flowy core module.
  """
  alias Mix.Flowy.Schema

  @type t :: %__MODULE__{
          base_module: atom,
          module: atom,
          alias: atom,
          file: String.t(),
          test_file: String.t(),
          schema: map(),
          generate?: boolean,
          dir: String.t(),
          context_app: atom,
          opts: Keyword.t()
        }

  defstruct base_module: nil,
            module: nil,
            alias: nil,
            file: nil,
            test_file: nil,
            schema: nil,
            generate?: false,
            context_app: nil,
            dir: nil,
            opts: []

  def new(core_name, opts) do
    new(core_name, %Schema{}, opts)
  end

  def new(core_name, %Schema{} = schema, opts) do
    basename = Phoenix.Naming.underscore(schema.plural)
    ctx_app = opts[:context_app] || Mix.Flowy.context_app()
    otp_app = Mix.Flowy.otp_app()
    basedir = Phoenix.Naming.underscore(core_name)
    dir = Mix.Flowy.context_lib_path(ctx_app, basedir)
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Flowy.context_base(ctx_app)

    %__MODULE__{
      context_app: opts[:context_app] || Mix.Flowy.context_app(),
      base_module: base,
      module: Module.concat([base, "Core", "#{schema.human_plural}"]),
      alias: schema.human_plural |> Module.concat(nil),
      file: Mix.Flowy.lib_path(:core, schema.context_app, basename <> ".ex"),
      test_file: Mix.Flowy.test_path(:core, schema.context_app, basename <> "_test.exs"),
      schema: schema,
      dir: dir,
      opts: opts
    }
  end

  def pre_existing?(%__MODULE__{file: file}), do: File.exists?(file)

  def pre_existing_tests?(%__MODULE__{test_file: file}), do: File.exists?(file)

  def function_count(%__MODULE__{file: file}) do
    {_ast, count} =
      file
      |> File.read!()
      |> Code.string_to_quoted!()
      |> Macro.postwalk(0, fn
        {:def, _, _} = node, count -> {node, count + 1}
        {:defdelegate, _, _} = node, count -> {node, count + 1}
        node, count -> {node, count}
      end)

    count
  end

  def file_count(%__MODULE__{dir: dir}) do
    dir
    |> Path.join("**/*.ex")
    |> Path.wildcard()
    |> Enum.count()
  end
end
