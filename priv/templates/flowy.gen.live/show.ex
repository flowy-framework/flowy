defmodule <%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Show do
  use <%= inspect core.web_module %>, :live_view

  alias <%= inspect core.module %>

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:<%= schema.singular %>, <%= inspect core.alias %>.get!(id))
     |> assign_defaults()}
  end

  defp assign_defaults(socket) do
    socket
    |> assign(:section, :<%= schema.collection %>)
    |> assign(:title, "Overview")
    |> assign_breadcrumb_steps()
  end

  defp assign_breadcrumb_steps(socket) do
    socket
    |> assign(:steps,
      [
        %Step{label: "Home", path: "/"},
        %Step{label: "<%= schema.human_plural %>", path: "<%= schema.route_prefix %>"},
        %Step{label: "REPLACE ME"}
      ]
    )
  end

  defp page_title(:show), do: "Show <%= schema.human_singular %>"
  defp page_title(:edit), do: "Edit <%= schema.human_singular %>"
  defp page_title(:show_delete), do: "Delete <%= schema.human_singular %>"
end
