defmodule <%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.FormComponent do
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
        phx-change="validate"
        event="save"
      >
<%= Mix.Tasks.Flowy.Gen.Html.indent_inputs(inputs, 8) %>
        <:actions>
          <.close_modal_button modal_id={@modal_id}/>
          <.save_modal_button />
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
  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset =
      socket.assigns.<%= schema.singular %>
      |> <%= inspect core.alias %>.change(<%= schema.singular %>_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    save_<%= schema.singular %>(socket, socket.assigns.action, <%= schema.singular %>_params)
  end

  defp save_<%= schema.singular %>(socket, :edit, <%= schema.singular %>_params) do
    case <%= inspect core.alias %>.update(socket.assigns.<%= schema.singular %>, <%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        notify_parent({:saved, <%= schema.singular %>})

        {:noreply,
         socket
         |> put_flash(:info, "<%= schema.human_singular %> updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_<%= schema.singular %>(socket, :new, <%= schema.singular %>_params) do
    case <%= inspect core.alias %>.create(<%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        notify_parent({:saved, <%= schema.singular %>})

        {:noreply,
         socket
         |> put_flash(:info, "<%= schema.human_singular %> created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
