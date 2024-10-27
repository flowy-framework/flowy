defmodule <%= @web_namespace %>.Router do
  @moduledoc false
  use <%= @web_namespace %>, :router<%= if @html do %>

  import <%= @web_namespace %>.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {<%= @web_namespace %>.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end<% end %>

  pipeline :unauthenticated_layout do
    plug :put_root_layout, html: {<%= @web_namespace %>.Layouts, :unauthenticated}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Flowy.Web.Plugs.CamelCaseDecoderPlug
  end<%= if @html do %>

  pipeline :api_spec do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: <%= @web_namespace %>.ApiSpec
  end

  scope "/api" do
    pipe_through [:api_spec]
    get "/specs", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api/i1", <%= @web_namespace %>.Controllers.Api, as: :api do
    pipe_through([:api])

    # Your api resources here
  end

  scope "/", <%= @web_namespace %> do
    pipe_through([:browser, :unauthenticated_layout, :redirect_if_user_is_authenticated])

    get("/sign-in", Controllers.SignInController, :new)
  end

  scope "/" do
    # TODO: Make sure you want to have this open in production
    pipe_through([:browser])
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/specs"
  end

  scope "/", <%= @web_namespace %> do
    pipe_through :browser

    live_session :authenticated, on_mount: [{<%= @web_namespace %>.UserAuth, :ensure_authenticated}] do
      live("/", Live.HomeLive, :show)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", <%= @web_namespace %> do
  #   pipe_through :api
  # end<% else %>

  scope "/api", <%= @web_namespace %> do
    pipe_through :api
  end<% end %><%= if @dashboard || @mailer do %>

  # Enable <%= [@dashboard && "LiveDashboard", @mailer && "Swoosh mailbox preview"] |> Enum.filter(&(&1)) |> Enum.join(" and ") %> in development
  if Application.compile_env(:<%= @web_app_name %>, :dev_routes) do<%= if @dashboard do %>
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router<% end %>

    scope "/dev" do<%= if @html do %>
      pipe_through :browser<% else %>
      pipe_through [:fetch_session, :protect_from_forgery]<% end %>
<%= if @dashboard do %>
      live_dashboard "/dashboard", metrics: <%= @web_namespace %>.Telemetry<% end %><%= if @mailer do %>
      forward "/mailbox", Plug.Swoosh.MailboxPreview<% end %>
    end
  end<% end %>
end
