defmodule Flowy.Web.Plugs.CamelCaseDecoderPlugTest do
  use ExUnit.Case
  use Plug.Test

  alias Flowy.Web.Plugs.CamelCaseDecoderPlug

  describe "call/2" do
    @describetag :camel_case_decoder_plug
    test "decodes params" do
      opts = CamelCaseDecoderPlug.init([])

      body = %{
        "user" => %{
          "firstName" => "Han",
          "lastName" => "Solo",
          "alliesInCombat" => [
            %{"name" => "Luke", "weaponOfChoice" => "lightsaber"},
            %{"name" => "Chewie", "weaponOfChoice" => "bowcaster"},
            %{"name" => "Leia", "weaponOfChoice" => "blaster"}
          ]
        }
      }

      conn =
        conn(:post, "/", body |> Jason.encode!())
        |> put_req_header("content-type", "application/json")
        |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
        |> CamelCaseDecoderPlug.call(opts)

      assert conn.params == %{
               "user" => %{
                 "allies_in_combat" => [
                   %{"name" => "Luke", "weapon_of_choice" => "lightsaber"},
                   %{"name" => "Chewie", "weapon_of_choice" => "bowcaster"},
                   %{"name" => "Leia", "weapon_of_choice" => "blaster"}
                 ],
                 "first_name" => "Han",
                 "last_name" => "Solo"
               }
             }
    end
  end
end
