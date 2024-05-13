defmodule Flowy.Support.Http.Request do
  @moduledoc """
  This module defines the behaviour for HTTP responses.
  """
  @type t :: %__MODULE__{
          method: atom(),
          url: String.t(),
          body: map() | nil,
          headers: list(),
          opts: keyword()
        }

  defstruct [:method, :url, :body, :headers, :opts]

  @doc """
  Builds a new request struct.
  """
  @spec build(method :: atom(), url :: String.t(), headers :: list(), body :: map() | nil, opts :: keyword()) :: t()
  def build(method, url, headers \\ [], body \\ nil, opts \\ []) do
    %__MODULE__{
      method: method,
      url: url,
      headers: headers,
      body: body,
      opts: opts
    }
  end
end
