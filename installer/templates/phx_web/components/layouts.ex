defmodule <%= @web_namespace %>.Layouts do
  @moduledoc false
  use <%= @web_namespace %>, :html

  embed_templates "layouts/*"
end
