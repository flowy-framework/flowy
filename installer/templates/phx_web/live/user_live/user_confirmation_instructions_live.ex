defmodule <%= @web_namespace %>.UserConfirmationInstructionsLive do
  use <%= @web_namespace %>, :live_view

  alias <%= @app_module %>.Hive.Core.Users

  def render(assigns) do
    ~H"""
    <div class="max-w-sm mx-auto">
      <p class="text-center">
        No confirmation instructions received?
        <span>We'll send a new confirmation link to your inbox</span>
      </p>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button
            phx-disable-with="Sending..."
            class="w-full"
            label="Resend confirmation instructions"
          />
        </:actions>
      </.simple_form>

      <p class="mt-4 text-center">
        <.link href={UrlHelper.register_path()}>Register</.link>
        | <.link href={UrlHelper.login_path()}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_confirmation_instructions(
        user,
        &unverified_url(socket, UrlHelper.user_confirm_path(&1))
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
