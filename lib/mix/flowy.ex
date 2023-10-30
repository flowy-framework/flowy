defmodule Mix.Flowy do
  @moduledoc """
  Mix tasks for Flowy.
  """
  alias alias Mix.Phoenix.Schema

  @switches [
    migration: :boolean,
    binary_id: :boolean,
    table: :string,
    web: :string,
    context_app: :string,
    prefix: :string,
    repo: :string,
    migration_dir: :string
  ]

  @doc """
  Path to the context's lib directory.
  """
  @spec lib_path(atom, atom, String.t()) :: String.t()
  def lib_path(resource, ctx_app, rel_path) do
    Mix.Phoenix.context_lib_path(ctx_app, "#{resource}/" <> rel_path)
  end

  @doc """
  Path to the context's test directory.
  """
  @spec test_path(atom, atom, String.t()) :: String.t()
  def test_path(resource, ctx_app, rel_path) do
    Mix.Phoenix.context_test_path(ctx_app, "#{resource}/" <> rel_path)
  end

  # @doc """
  # Returns the query lib path to be used in generated files.
  # """
  # def query_lib_path(ctx_app, rel_path) when is_atom(ctx_app) do
  #   Mix.Phoenix.context_lib_path(ctx_app, "queries/" <> rel_path)
  # end

  # def query_test_path(ctx_app, rel_path) when is_atom(ctx_app) do
  #   Mix.Phoenix.context_test_path(ctx_app, "queries/" <> rel_path)
  # end

  def test_path(rel_path) do
    Mix.Phoenix.context_app() |> dbg()
    Mix.Phoenix.context_app() <> rel_path
  end

  def context_test_path(ctx_app, rel_path) when is_atom(ctx_app) do
    Mix.Phoenix.context_app_path(ctx_app, Path.join(["test", rel_path]))
  end

  @doc false
  def validate_args!([schema, plural | _] = args, help) do
    cond do
      not Schema.valid?(schema) ->
        help.raise_with_help(
          "Expected the schema argument, #{inspect(schema)}, to be a valid module name"
        )

      String.contains?(plural, ":") or plural != Phoenix.Naming.underscore(plural) ->
        help.raise_with_help(
          "Expected the plural argument, #{inspect(plural)}, to be all lowercase using snake_case convention"
        )

      true ->
        args
    end
  end

  def validate_args!(_, help) do
    help.raise_with_help("Invalid arguments")
  end

  @doc false
  def pre_build(args, parent_opts, help, switches \\ @switches) do
    {schema_opts, parsed, _} = OptionParser.parse(args, switches: switches)
    [schema_name, plural | attrs] = validate_args!(parsed, help)

    opts =
      parent_opts
      |> Keyword.merge(schema_opts)
      |> put_context_app(schema_opts[:context_app])
      |> maybe_update_repo_module()

    {schema_name, plural, attrs, opts}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  defp maybe_update_repo_module(opts) do
    if is_nil(opts[:repo]) do
      opts
    else
      Keyword.update!(opts, :repo, &Module.concat([&1]))
    end
  end
end
