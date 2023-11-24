Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Flowy.Gen.CoreTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Flowy.Gen
  alias Mix.Flowy.{Core, Schema}

  setup do
    Mix.Task.clear()
    :ok
  end

  @tag :gen_core_build
  test "build" do
    in_tmp_project("build", fn ->
      {core, schema} = Gen.Core.build(~w(Users User users name:string age:integer), [])

      assert %Core{
               alias: Users,
               module: Flowy.Core.Users
             } = core

      assert String.ends_with?(core.file, "lib/flowy/core/users.ex")

      assert %Schema{
               alias: User,
               module: Flowy.Schemas.User
             } = schema
    end)
  end

  @tag :gen_core_run
  test "generates files", config do
    in_tmp_project(config.test, fn ->
      Gen.Core.run(~w(User users name:string age:integer))

      assert_file("lib/flowy/schemas/user.ex")
      assert_file("lib/flowy/queries/user_query.ex")
      assert_file("test/flowy/queries/user_query_test.exs")
      assert_file("test/support/fixtures/user_fixtures.ex")

      assert_file("lib/flowy/core/users.ex", fn file ->
        assert file =~ "defmodule Flowy.Core.Users do"
      end)

      assert_file("test/flowy/core/users_test.exs", fn file ->
        assert file =~ "defmodule Flowy.Core.UsersTest do"
      end)
    end)
  end
end
