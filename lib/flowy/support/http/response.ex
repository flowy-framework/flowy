defmodule Flowy.Support.Http.Response do
  @moduledoc """
  This module defines the behaviour for HTTP responses.
  """
  @type t :: %__MODULE__{
          body: map() | list(),
          http_code: integer(),
          headers: map(),
          error: any()
        }

  defstruct [:body, :http_code, :headers, :error]
end
