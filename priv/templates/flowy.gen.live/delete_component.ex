defmodule <%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.DeleteComponent do
  use <%= inspect core.web_module %>, :live_component

  alias <%= inspect core.module %>

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="<%= schema.singular %>-form"
        target={@myself}
        event="delete"
      >
      <.alert icon="fa-solid fa-triangle-exclamation text-xl" color={:error} description="Are you sure you want to delete the following <%= schema.human_singular %>?" />
        <.card>
          <div class="space-y-3">
            <%= for {k, _} <- schema.attrs do %><.card_field value={@<%= schema.singular %>.<%= k %>} label="<%= Phoenix.Naming.humanize(Atom.to_string(k)) %>" /><% end %>
            <.card_line />
            <.card_formatted_field format="date_from_now" value={@<%= schema.singular %>.inserted_at} label="Inserted at" />
            <.card_formatted_field format="date_from_now" value={@<%= schema.singular %>.updated_at} label="Updated at" />
          </div>
        </.card>
        <:actions>
          <.close_modal_button modal_id={@modal_id}/>
          <.delete_modal_button />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{<%= schema.singular %>: <%= schema.singular %>} = assigns, socket) do
    changeset = <%= inspect core.alias %>.change(<%= schema.singular %>)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    delete_<%= schema.singular %>(socket, socket.assigns.action)
  end

  defp delete_<%= schema.singular %>(socket, :delete) do
    case <%= inspect core.alias %>.delete(socket.assigns.<%= schema.singular %>) do
      {:ok, _<%= schema.singular %>} ->
        notify_parent({:deleted, <%= schema.singular %>})

        {:noreply,
         socket
         |> put_flash(:info, "<%= schema.human_singular %> deleted successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp delete_<%= schema.singular %>(socket, :show_delete) do
    case <%= inspect core.alias %>.delete(socket.assigns.<%= schema.singular %>) do
      {:ok, <%= schema.singular %>} ->
        {:noreply,
         socket
         |> put_flash(:info, "<%= schema.human_singular %> deleted successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
