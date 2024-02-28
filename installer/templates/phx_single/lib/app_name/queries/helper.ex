defmodule <%= @app_module %>.Queries.Helper do
  import Ecto.Query

  def handle_preloads(%Ecto.Query{} = query, opts) do
    preloads = Keyword.get(opts, :preload, [])

    query
    |> preload(^preloads)
  end

  def handle_preloads(query, opts) do
    preloads = Keyword.get(opts, :preload, [])

    query
    |> <%= @app_module %>.Repo.preload(preloads)
  end
end
