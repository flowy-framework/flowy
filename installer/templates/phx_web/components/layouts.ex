defmodule <%= @web_namespace %>.Layouts do
  @moduledoc false
  use <%= @web_namespace %>, :html

  alias <%= @app_module %>.Schemas.User

  embed_templates "layouts/*"

  def build_paleta_user(
        %{
          first_name: first_name,
          last_name: last_name,
          email: email
        } = user
      ) do
    %Paleta.Components.SidebarProfile.User{
      first_name: first_name,
      last_name: last_name,
      email: email,
      avatar_url: User.default_avatar_url(user)
    }
  end
end
