defmodule <%= @app_module %>.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :<%= @app_name %>,
    adapter: <%= inspect @adapter_module %>
end
