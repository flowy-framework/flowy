defmodule <%= @web_namespace %>.UserForgotPasswordLive do
  use <%= @web_namespace %>, :unauthenticated_live_view

  alias <%= @app_module %>.Hive.Core.Users
  alias <%= @web_namespace %>.Live.UrlHelper

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_reset_password_instructions(
        user,
        &unverified_url(socket, UrlHelper.reset_password_path(&1))
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: UrlHelper.reset_password_path())}
  end
end
