defmodule Flowy.Web.Plugs.CamelCaseDecoderPlug do
  @moduledoc """
  Converts all plug params to snake case.

  ## Usage

  Add `Flowy.Web.Plugs.CamelCaseDecoderPlug` to your api pipeline:

  ```elixir
  # router.ex
  pipeline :api do
    plug :accepts, ["json"]
    plug Flowy.Web.Plugs.CamelCaseDecoderPlug
  end
  ```

  Now, all request bodies and params will be converted to snake case.
  """
  @behaviour Plug

  alias Flowy.Utils.Case

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    case conn.params do
      %Plug.Conn.Unfetched{} -> conn
      _ -> %{conn | params: Case.to_snake_case(conn.params)}
    end
  end
end
