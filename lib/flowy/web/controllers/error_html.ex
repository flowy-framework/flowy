defmodule Flowy.Web.Controllers.ErrorHTML do
  @moduledoc """
  This module is responsible for rendering error pages
  """

  use Phoenix.Component

  import Palette.Components.ErrorPage

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/one_seven_web/controllers/error_html/404.html.heex
  #   * lib/one_seven_web/controllers/error_html/500.html.heex
  #
  embed_templates("error_html/*")

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  @doc """
  Renders an error page.
  """
  @spec render(String.t(), any()) :: String.t()
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
