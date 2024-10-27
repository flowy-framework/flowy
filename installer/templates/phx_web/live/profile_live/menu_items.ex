defmodule <%= @web_namespace %>.ProfileLive.MenuItems do
  alias <%= @web_namespace %>.Live.UrlHelper
  alias Paleta.Components.CardWithSideMenu.Item

  def all() do
    [
      Item.build(
        :general,
        "Profile",
        "fa-solid fa-gear",
        UrlHelper.profile_path()
      ),
      Item.build(
        :activity,
        "Activity",
        "fa-solid fa-timeline",
        UrlHelper.profile_activity_path()
      )
    ]
  end
end
