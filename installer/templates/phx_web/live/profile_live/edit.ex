defmodule <%= @web_namespace %>.Live.ProfileLive.Edit do
  use <%= @web_namespace %>, :no_workspace_live_view

  alias <%= @app_module %>.Hive.Core.Users
  alias <%= @app_module %>.Hive.Schemas.User
  alias <%= @web_namespace %>.ProfileLive.MenuItems

  import <%= @web_namespace %>.Live.Components.UploadErrorsComponent

  @impl true
  def mount(_params, _session, socket) do
    changeset = User.update_changeset(socket.assigns.current_user, %{})

    {:ok,
     socket
     |> assign_defaults()
     |> assign_breadcrumb_steps()
     |> assign_submenu_items()
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar_url,
       accept: ~w(.jpg .jpeg .png .webp .avif),
       max_entries: 1,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign_form(changeset)}
  end

  defp assign_defaults(socket) do
    socket
    |> assign(:context, :launchpad)
    |> assign(:section, :general)
    |> assign(:title, "Edit Your Profile")
    |> assign_breadcrumb_steps()
  end

  defp assign_submenu_items(socket) do
    socket
    |> assign(:menu_items, MenuItems.all())
    |> assign(:menu_item_active, :general)
  end

  defp assign_breadcrumb_steps(socket) do
    socket
    |> assign(:steps, [
      %Step{label: "Launchpad", path: UrlHelper.launchpad_path()},
      %Step{label: "Profile"},
      %Step{label: "Edit"}
    ])
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket |> assign(:form, to_form(changeset))
  end

  def update(%{current_user: current_user} = assigns, socket) do
    changeset = Users.change(current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Users.change(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp handle_progress(
         :avatar_url,
         %{done?: true, valid?: true, cancelled?: false},
         %{assigns: %{current_user: user}} = socket
       ) do
    user_avatar = socket |> put_photo_urls()
    update = Users.update_avatar(user, user_avatar)

    case update do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile avatar updated successfully")
         |> push_navigate(to: UrlHelper.profile_path())}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Profile avatar update failed")}
    end
  end

  defp handle_progress(:avatar_url, _entry, socket), do: {:noreply, socket}

  defp put_photo_urls(%{assigns: %{current_user: user}} = socket) do
    [file_path] =
      consume_uploaded_entries(socket, :avatar_url, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    %{
      "avatar_url" => file_path
    }
  end

  defp save_user(socket, :edit, user_params) do
    case Users.update(socket.assigns.current_user, user_params) do
      {:ok, current_user} ->
        notify_parent({:saved, current_user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: UrlHelper.profile_path())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def choose_button_class(%{default: true}) do
    "btn rounded-full bg-primary font-medium text-white hover:bg-primary-focus focus:bg-primary-focus active:bg-primary-focus/90 dark:bg-accent dark:hover:bg-accent-focus dark:focus:bg-accent-focus dark:active:bg-accent/90"
  end

  def choose_button_class(%{default: false}) do
    "btn rounded-full border border-slate-200 font-medium text-primary hover:bg-slate-150 focus:bg-slate-150 active:bg-slate-150/80 dark:border-navy-500 dark:text-accent-light dark:hover:bg-navy-500 dark:focus:bg-navy-500 dark:active:bg-navy-500/90"
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
