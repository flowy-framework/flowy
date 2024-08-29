defmodule <%= @web_namespace %>.Controllers.ErrorJSON do
  @moduledoc """
  This module is responsible for rendering apis error
  """

  use Phoenix.Component

  @doc """
  If you want to customize a particular status code,
  you may add your own clauses, such as:

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  By default, Phoenix returns the status message from
  the template name. For example, "404.json" becomes
  "Not Found".
  """

  def render("403.json", _assigns) do
    %{code: code, description: description} = Flowy.config().service.codes |> Keyword.get(:"403")
    %{errors: [%{error_code: code, error_message: description}]}
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
