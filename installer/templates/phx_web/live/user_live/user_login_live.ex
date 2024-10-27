defmodule <%= @web_namespace %>.UserLoginLive do
  use <%= @web_namespace %>, :unauthenticated_live_view

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
