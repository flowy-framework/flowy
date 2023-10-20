defmodule Flowy.Support.Http.Client do
  @moduledoc """
  This module defines the behaviour for HTTP clients.
  """
  @type request :: Flowy.Support.Http.Request.t()
  @type response :: Flowy.Support.Http.Response.t()

  @callback request(request) :: {:ok, response} | {:error, response}
end
