defmodule Flowy.Config do
  @moduledoc """
  This module defines a struct that contains all of the fields necessary to configure
  an instance of Flowy.
  """
  alias Flowy.Config.Service

  @type t :: %__MODULE__{
          name: String.t(),
          service: Service.t()
        }

  defstruct [
    :name,
    :service
  ]

  @doc """
  Builds a Flowy configuration struct with the given options.
  """
  @spec build(map()) :: t()
  def build(opts) do
    %__MODULE__{
      name: Keyword.get(opts, :name, "Flowy"),
      service: service(Keyword.get(opts, :service, []))
    }
  end

  def test?() do
    System.get_env("MIX_ENV", "test") == "test"
  end

  def run_server?() do
    System.get_env("PHX_SERVER") != nil
  end

  def secret!(env) do
    if secret_key_base = System.get_env(env) do
      if byte_size(secret_key_base) < 64 do
        abort!(
          "cannot start service because #{env} must be at least 64 characters. " <>
            "Invoke `openssl rand -base64 48` to generate an appropriately long secret."
        )
      end

      secret_key_base
    end
  end

  def db_ssl!(env) do
    if ssl = System.get_env(env) do
      if ssl == "true" do
        true
      else
        false
      end
    else
      false
    end
  end

  @doc """
  Parses and validates the port from env.
  """
  def port!(env) do
    if port = System.get_env(env) do
      case Integer.parse(port) do
        {port, ""} -> port
        :error -> abort!("expected #{env} to be an integer, got: #{inspect(port)}")
      end
    end
  end

  def hostname!(env) do
    if hostname = System.get_env(env) do
      hostname
    end
  end

  @doc """
  Parses and validates the ip from env.
  """
  def ip!(env) do
    if ip = System.get_env(env) do
      ip!(env, ip)
    end
  end

  @doc """
  Parses and validates the ip within context.
  """
  def ip!(context, ip) do
    case ip |> String.to_charlist() |> :inet.parse_address() do
      {:ok, ip} ->
        ip

      {:error, :einval} ->
        abort!("expected #{context} to be a valid ipv4 or ipv6 address, got: #{ip}")
    end
  end

  @doc """
  Parses the cookie from env.
  """
  def cookie!(env) do
    if cookie = System.get_env(env) do
      String.to_atom(cookie)
    end
  end

  @doc """
  Aborts booting due to a configuration error.
  """
  @spec abort!(String.t()) :: no_return()
  def abort!(message) do
    IO.puts("\nERROR!!! Flowy " <> message)
    halt(1, test?())
  end

  defp halt(value, true = _test) do
    {:halt, value}
  end

  defp halt(value, false = _test) do
    System.halt(value)
  end

  defp service([]) do
    %Service{
      keys_format: :snake_case,
      codes: [
        "403": %{
          code: "002",
          description: "Forbidden: Something doesn't look quite right. Double check it, will you?"
        }
      ]
    }
  end
end
