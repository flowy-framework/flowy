defmodule Flowy.ConfigTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Flowy.Config
  alias Flowy.Config.Service

  describe "Flowy.Config" do
    @describetag :flowy_config

    test "development?/0" do
      assert Config.development?() == true
    end

    test "secret!/1" do
      System.put_env("EMPTY", "wrong value")

      assert capture_io(fn -> Config.secret!("EMPTY") end) =~
      "\nERROR!!! Flowy cannot start service because EMPTY must be at least 64 characters. Invoke `openssl rand -base64 48` to generate an appropriately long secret.\n"
    end

    test "db_ssl!/1" do
      System.put_env("DB_SSL", "true")

      assert Config.db_ssl!("DB_SSL")
    end

    test "port!/1" do
      System.put_env("PORT", "2123")

      assert Config.port!("PORT") == 2123
    end

    test "port!/1 with invalid port" do
      System.put_env("PORT", "invalid")

      assert capture_io(fn -> Config.port!("PORT") end) =~
      "\nERROR!!! Flowy expected PORT to be an integer, got: \"invalid\"\n"
    end

    test "hostname!/1" do
      System.put_env("HOSTNAME", "localhost")

      assert Config.hostname!("HOSTNAME") == "localhost"
    end

    test "ip!/1" do
      System.put_env("TEST_IP", "127.0.0.1")
      assert Config.ip!("TEST_IP") ==  {127, 0, 0, 1}
    end

    test "ip!/1 with invalid data" do
      System.put_env("TEST_IP", "invalid_id")
      assert capture_io(fn -> Config.ip!("TEST_IP") end) =~
      "\nERROR!!! Flowy expected TEST_IP to be a valid ipv4 or ipv6 address, got: invalid_id\n"
    end

    test "Flowy.Config.build/1 is created with correct default values" do
      config = Config.build([])

      assert config == %Config{
               name: "Flowy",
               service: %Service{
                 keys_format: :snake_case,
                 codes: [
                   "403": %{
                     code: "002",
                     description:
                       "Forbidden: Something doesn't look quite right. Double check it, will you?"
                   }
                 ]
               }
             }
    end
  end
end
