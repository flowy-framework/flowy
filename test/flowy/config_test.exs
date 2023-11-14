defmodule Flowy.ConfigTest do
  use ExUnit.Case, async: true

  alias Flowy.Config
  alias Flowy.Config.Service

  describe "Flowy.Config" do
    @describetag :flowy_config
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
