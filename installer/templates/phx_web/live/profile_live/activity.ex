defmodule <%= @web_namespace %>.Live.ProfileLive.Activity do
  use <%= @web_namespace %>, :live_view

  alias <%= @web_namespace %>.ProfileLive.MenuItems

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_defaults()
     |> assign_breadcrumb_steps()
     |> assign_submenu_items()}
  end

  defp assign_defaults(socket) do
    socket
    |> assign(:context, :launchpad)
    |> assign(:section, :activity)
    |> assign(:title, "Activity")
  end

  defp assign_submenu_items(socket) do
    socket
    |> assign(:menu_items, MenuItems.all())
    |> assign(:menu_item_active, :activity)
  end

  defp assign_breadcrumb_steps(socket) do
    socket
    |> assign(:steps, [
      %Step{label: "Launchpad", path: UrlHelper.launchpad_path()},
      %Step{label: "Profile"},
      %Step{label: "Activity"}
    ])
  end
end
