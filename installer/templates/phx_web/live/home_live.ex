defmodule <%= @web_namespace %>.Live.HomeLive do
  use <%= @web_namespace %>, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:section, :home)}
  end
end
