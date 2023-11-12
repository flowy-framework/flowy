defmodule FlowyTest do
  use ExUnit.Case
  doctest Flowy

  describe "Flowy" do
    @describetag :flowy

    setup do
      start_supervised(Flowy)

      :ok
    end

    test "config" do
      assert %Flowy.Config{
               service: %Flowy.Config.Service{
                 keys_format: :snake_case,
                 codes: [
                   "403": %{
                     code: "002",
                     description:
                       "Forbidden: Something doesn't look quite right. Double check it, will you?"
                   }
                 ]
               }
             } = Flowy.config()
    end

    test "keys_format" do
      assert Flowy.config().service.keys_format == :snake_case
    end
  end
end
