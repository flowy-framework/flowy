defmodule Flowy.Prometheus do
  @moduledoc """
  This module is responsible for configuring the PromEx library
  """

  use PromEx, otp_app: config(:opt_app)

  alias PromEx.Plugins

  @impl true
  def plugins do
    config(:plugins)
    |> Enum.map(fn key ->
      plugin(key)
    end)
    |> Enum.concat(custom_plugins())
  end

  def custom_plugins() do
    [Flowy.Prometheus.HttpPlugin]
  end

  def plugin(:phoenix) do
    module_name = config(:module_name)
    router = "#{module_name}Web.Router" |> String.to_existing_atom()
    endpoint = "#{module_name}Web.Endpoint" |> String.to_existing_atom()
    {Plugins.Phoenix, router: router, endpoint: endpoint}
  end

  def plugin(plugin) do
    plugin_name = plugin |> Atom.to_string() |> Macro.camelize()
    "Elixir.PromEx.Plugins.#{plugin_name}" |> String.to_existing_atom()
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: config(:datasource_id),
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    config(:dashboards)
    |> Enum.map(fn dashboard ->
      {:prom_ex, "#{dashboard}.json"}
    end)
  end

  def config(key) do
    Application.get_env(:flowy, :prometheus) |> Keyword.get(key)
  end
end
