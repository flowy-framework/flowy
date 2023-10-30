Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Flowy.Gen.SchemaTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Flowy.Gen
  alias Mix.Phoenix.Schema

  setup do
    Mix.Task.clear()
    :ok
  end

  @tag :gen_schema_build
  test "build" do
    in_tmp_project("build", fn ->
      schema = Gen.Schema.build(~w(User users name:string age:integer), [])

      assert %Schema{
               alias: User,
               # TODO: This should be Flowy.Schemas.User
               module: Flowy.Schemas.User,
               repo: Flowy.Repo,
               file: "lib/flowy/schemas/user.ex"
             } = schema

      assert String.ends_with?(schema.file, "lib/flowy/schemas/user.ex")
    end)
  end

  @tag :gen_schema_run
  test "generates files", config do
    in_tmp_project(config.test, fn ->
      Gen.Schema.run(~w(User users name:string age:integer))

      assert_file("lib/flowy/schemas/user.ex", fn file ->
        assert file =~ "defmodule Flowy.Schemas.User do"
      end)
    end)
  end
end
