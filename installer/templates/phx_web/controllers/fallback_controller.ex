defmodule <%= @web_namespace %>.Controllers.FallbackController do
  @moduledoc """
  A fallback plug is useful to translate common domain data structures
  into a valid `%Plug.Conn{}` response. If the controller action fails to
  return a `%Plug.Conn{}`, the provided plug will be called and receive
  the controller's `%Plug.Conn{}` as it was before the action was invoked
  along with the value returned from the controller action.
  """
  use Phoenix.Controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: <%= @web_namespace %>.Controllers.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: <%= @web_namespace %>.Controllers.ErrorHTML, json: <%= @web_namespace %>.Controllers.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: <%= @web_namespace %>.Controllers.ErrorJSON)
    |> render(:error, message: error)
  end
end
