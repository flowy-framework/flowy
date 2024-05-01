defmodule Flowy.Support.Http.FinchClient do
  @moduledoc """
  This module defines the behaviour for HTTP clients.
  """

  # TODO: If we introduce another http client, we want to make sure that finch is
  # loaded before trying to use it.

  @behaviour Flowy.Support.Http.Client
  alias Flowy.Support.Http.Request

  @type request :: Flowy.Support.Http.Request.t()
  @type response :: Flowy.Support.Http.Response.t()

  @impl true
  @doc """
  Makes an HTTP request using Finch.
  """
  @spec request(request) ::
          {:error, any()}
          | {:ok, response}
  def request(%Request{method: method, url: url, body: body, headers: headers, opts: opts}) do
    Finch.build(method, url, headers, body_to_json(body))
    |> Finch.request(Flowy.Finch, opts)
    |> build_response()
  end

  defp body_to_json(nil), do: ""
  defp body_to_json(""), do: ""
  defp body_to_json(body_form) when is_binary(body_form), do: body_form
  defp body_to_json(body), do: body |> Jason.encode!()

  defp build_response({:ok, %Finch.Response{body: body, headers: headers, status: status_code}})
       when status_code >= 200 and status_code <= 299 do
    {:ok,
     %Flowy.Support.Http.Response{
       body: parse_body(body),
       headers: headers,
       http_code: status_code
     }}
  end

  defp build_response({:ok, %Finch.Response{body: body, headers: headers, status: status_code}}) do
    {:error,
     %Flowy.Support.Http.Response{
       body: parse_body(body),
       headers: headers,
       http_code: status_code
     }}
  end

  defp build_response({:error, %Mint.TransportError{reason: reason}}) do
    {:error,
     %Flowy.Support.Http.Response{
       body: %{},
       headers: %{},
       http_code: 500,
       error: reason
     }}
  end

  defp build_response({:error, error}) do
    {:error,
     %Flowy.Support.Http.Response{
       body: %{},
       headers: %{},
       http_code: 500,
       error: error
     }}
  end

  # Im assuming all the APIs we are comsuming are JSON based
  # if we can't convert to JSON, we just return the body as is
  defp parse_body(body) do
    case Jason.decode(body) do
      {:ok, decoded_body} -> decoded_body
      {:error, _} -> body
    end
  end
end
