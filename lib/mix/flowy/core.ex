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
          schema: Mix.Flowy.Schema.t(),
          query: Mix.Flowy.Query.t(),
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
            query: nil,
            generate?: false,
            context_app: nil,
            dir: nil,
            opts: []

  @doc """
  Builds a core module struct from a schema.
  """
  @spec new(String.t(), Keyword.t()) :: t()
  def new(core_name, opts) do
    new(core_name, %Schema{}, opts)
  end

  @doc """
  Builds a core module struct from a schema.
  """
  @spec new(String.t(), t(), Keyword.t()) :: t()
  def new(core_name, %Schema{} = schema, opts) do
    basename = Phoenix.Naming.underscore(schema.plural)
    ctx_app = opts[:context_app] || Mix.Flowy.context_app()
    otp_app = Mix.Flowy.otp_app()
    basedir = Phoenix.Naming.underscore(core_name)
    dir = Mix.Flowy.context_lib_path(ctx_app, basedir)
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Flowy.context_base(ctx_app)
    query = Mix.Flowy.Query.new(schema, opts)

    %__MODULE__{
      context_app: opts[:context_app] || Mix.Flowy.context_app(),
      base_module: base,
      query: query,
      module: Module.concat([base, "Core", "#{schema.human_plural}"]),
      alias: schema.human_plural |> Module.concat(nil),
      file: Mix.Flowy.lib_path(:core, schema.context_app, basename <> ".ex"),
      test_file: Mix.Flowy.test_path(:core, schema.context_app, basename <> "_test.exs"),
      schema: schema,
      dir: dir,
      opts: opts
    }
  end

  @doc """
  Validates the core module name.
  """
  @spec valid?(String.t()) :: boolean()
  def valid?(core) do
    core =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  @doc """
  Check if the core module already exists.
  """
  @spec pre_existing?(t()) :: boolean()
  def pre_existing?(%__MODULE__{file: file}), do: File.exists?(file)

  @doc """
  Check if the core test module already exists.
  """
  @spec pre_existing_tests?(t()) :: boolean()
  def pre_existing_tests?(%__MODULE__{test_file: file}), do: File.exists?(file)

  @doc false
  @spec function_count(t()) :: non_neg_integer()
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

  @doc false
  @spec file_count(t()) :: non_neg_integer()
  def file_count(%__MODULE__{dir: dir}) do
    dir
    |> Path.join("**/*.ex")
    |> Path.wildcard()
    |> Enum.count()
  end
end
