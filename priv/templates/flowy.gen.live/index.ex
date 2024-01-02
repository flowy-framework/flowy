defmodule <%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use <%= inspect core.web_module %>, :live_view

  alias <%= inspect core.module %>
  alias <%= inspect schema.module %>

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :<%= schema.collection %>, <%= inspect core.alias %>.all()) |> assign_defaults()}
  end

  defp assign_defaults(socket) do
    socket
    |> assign(:section, :<%= schema.collection %>)
    |> assign(:title, "<%= schema.human_plural %>")
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, <%= inspect core.alias %>.get!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, %<%= inspect schema.alias %>{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing <%= schema.human_plural %>")
    |> assign(:<%= schema.singular %>, nil)
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    socket
    |> assign(:page_title, "Delete <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, <%= inspect core.alias %>.get!(id))
  end

  @impl true
  def handle_info({<%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.FormComponent, {:saved, <%= schema.singular %>}}, socket) do
    {:noreply, stream_insert(socket, :<%= schema.collection %>, <%= schema.singular %>)}
  end

  @impl true
  def handle_info({<%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.DeleteComponent, {:deleted, <%= schema.singular %>}}, socket) do
    {:noreply, stream_delete(socket, :<%= schema.collection %>, <%= schema.singular %>)}
  end
end
