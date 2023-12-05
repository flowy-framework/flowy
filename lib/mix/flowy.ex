defmodule Mix.Flowy do
  @moduledoc """
  Mix tasks for Flowy.
  """
  alias alias Mix.Flowy.Schema

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
  Returns the module base name based on the configuration value.

      config :my_app
        namespace: My.App

  """
  def base do
    app_base(otp_app())
  end

  @doc """
  Returns the context module base name based on the configuration value.

      config :my_app
        namespace: My.App

  """
  def context_base(ctx_app) do
    app_base(ctx_app)
  end

  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string() |> Phoenix.Naming.camelize()
      mod -> mod |> inspect()
    end
  end

  @doc """
  Path to the context's lib directory.
  """
  @spec lib_path(atom, atom, String.t()) :: String.t()
  def lib_path(resource, ctx_app, rel_path) do
    context_lib_path(ctx_app, "#{resource}/" <> rel_path)
  end

  @doc """
  Returns the context lib path to be used in generated context files.
  """
  def context_lib_path(ctx_app, rel_path) when is_atom(ctx_app) do
    context_app_path(ctx_app, Path.join(["lib", to_string(ctx_app), rel_path]))
  end

  @doc """
  Path to the context's test directory.
  """
  @spec test_path(atom, atom, String.t()) :: String.t()
  def test_path(resource, ctx_app, rel_path) do
    context_test_path(ctx_app, "#{ctx_app}/#{resource}/" <> rel_path)
  end

  @doc """
  Returns the web prefix to be used in generated file specs.
  """
  def web_path(ctx_app, rel_path \\ "") when is_atom(ctx_app) do
    this_app = otp_app()

    if ctx_app == this_app do
      Path.join(["lib", "#{this_app}_web", rel_path])
    else
      Path.join(["lib", to_string(this_app), rel_path])
    end
  end

  @doc """
  Returns the test prefix to be used in generated file specs.
  """
  def web_test_path(ctx_app, rel_path \\ "") when is_atom(ctx_app) do
    this_app = otp_app()

    if ctx_app == this_app do
      Path.join(["test", "#{this_app}_web", rel_path])
    else
      Path.join(["test", to_string(this_app), rel_path])
    end
  end

  @doc """
  Returns the context app path prefix to be used in generated context files.
  """
  def context_app_path(ctx_app, rel_path) when is_atom(ctx_app) do
    this_app = otp_app()

    if ctx_app == this_app do
      rel_path
    else
      app_path =
        case Application.get_env(this_app, :generators)[:context_app] do
          {^ctx_app, path} -> Path.relative_to_cwd(path)
          _ -> mix_app_path(ctx_app, this_app)
        end

      Path.join(app_path, rel_path)
    end
  end

  defp mix_app_path(app, this_otp_app) do
    case Mix.Project.deps_paths() do
      %{^app => path} ->
        Path.relative_to_cwd(path)

      deps ->
        Mix.raise("""
        no directory for context_app #{inspect(app)} found in #{this_otp_app}'s deps.

        Ensure you have listed #{inspect(app)} as an in_umbrella dependency in mix.exs:

            def deps do
              [
                {:#{app}, in_umbrella: true},
                ...
              ]
            end

        Existing deps:

            #{inspect(Map.keys(deps))}

        """)
    end
  end

  @doc """
  Returns the OTP app from the Mix project configuration.
  """
  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  @doc """
  Returns the OTP context app.
  """
  def context_app do
    this_app = otp_app()

    case fetch_context_app(this_app) do
      {:ok, app} -> app
      :error -> this_app
    end
  end

  defp fetch_context_app(this_otp_app) do
    case Application.get_env(this_otp_app, :generators)[:context_app] do
      nil ->
        :error

      false ->
        Mix.raise("""
        no context_app configured for current application #{this_otp_app}.

        Add the context_app generators config in config.exs, or pass the
        --context-app option explicitly to the generators. For example:

        via config:

            config :#{this_otp_app}, :generators,
              context_app: :some_app

        via cli option:

            mix phx.gen.[task] --context-app some_app

        Note: cli option only works when `context_app` is not set to `false`
        in the config.
        """)

      {app, _path} ->
        {:ok, app}

      app ->
        {:ok, app}
    end
  end

  def test_path(rel_path) do
    context_app() <> rel_path
  end

  def context_test_path(ctx_app, rel_path) when is_atom(ctx_app) do
    context_app_path(ctx_app, Path.join(["test", rel_path]))
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

  @doc """
  The paths to look for template files for generators.

  Defaults to checking the current app's `priv` directory,
  and falls back to Flowy's `priv` directory.
  """
  def generator_paths do
    [".", :flowy]
  end

  @doc """
  Prompts to continue if any files exist.
  """
  def prompt_for_conflicts(generator_files) do
    file_paths =
      Enum.flat_map(generator_files, fn
        {:new_eex, _, _path} -> []
        {_kind, _, path} -> [path]
      end)

    case Enum.filter(file_paths, &File.exists?(&1)) do
      [] ->
        :ok

      conflicts ->
        Mix.shell().info("""
        The following files conflict with new files to be generated:

        #{Enum.map_join(conflicts, "\n", &"  * #{&1}")}

        See the --web option to namespace similarly named resources
        """)

        unless Mix.shell().yes?("Proceed with interactive overwrite?") do
          System.halt()
        end
    end
  end

  @doc """
  Copies files from source dir to target dir
  according to the given map.

  Files are evaluated against EEx according to
  the given binding.
  """
  def copy_from(apps, source_dir, binding, mapping) when is_list(mapping) do
    roots = Enum.map(apps, &to_app_source(&1, source_dir))

    for {format, source_file_path, target} <- mapping do
      source =
        Enum.find_value(roots, fn root ->
          source = Path.join(root, source_file_path)
          if File.exists?(source), do: source
        end) || raise "could not find #{source_file_path} in any of the sources"

      case format do
        :text ->
          Mix.Generator.create_file(target, File.read!(source))

        :eex ->
          Mix.Generator.create_file(target, EEx.eval_file(source, binding))

        :new_eex ->
          if File.exists?(target) do
            :ok
          else
            Mix.Generator.create_file(target, EEx.eval_file(source, binding))
          end
      end
    end
  end

  defp to_app_source(path, source_dir) when is_binary(path),
    do: Path.join(path, source_dir)

  defp to_app_source(app, source_dir) when is_atom(app),
    do: Application.app_dir(app, source_dir)

  def to_text(data) do
    inspect(data, limit: :infinity, printable_limit: :infinity)
  end

  def prepend_newline(string) do
    "\n" <> string
  end
end
