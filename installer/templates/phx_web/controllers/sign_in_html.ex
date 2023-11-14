defmodule <%= @web_namespace %>.SignInHTML do
  use <%= @web_namespace %>, :html

  embed_templates("sign_in/*")
end
