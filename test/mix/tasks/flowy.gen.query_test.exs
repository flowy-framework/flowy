Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Flowy.Gen.QueryTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Flowy.Gen
  alias Mix.Phoenix.Schema
  alias Mix.Flowy.Query

  setup do
    Mix.Task.clear()
    :ok
  end

  @tag :gen_query_build
  test "build" do
    in_tmp_project("build", fn ->
      query = Gen.Query.build(~w(User users name:string age:integer), [])

      assert %Query{
               module: Flowy.Queries.UserQuery,
               file: "lib/flowy/queries/user_query.ex",
               schema: %Schema{
                 alias: User,
                 # TODO: This should be Flowy.Schemas.User
                 module: Flowy.Schemas.User,
                 repo: Flowy.Repo
               }
             } = query

      assert String.ends_with?(query.file, "lib/flowy/queries/user_query.ex")
    end)
  end

  @tag :gen_query_run
  test "generates files", config do
    in_tmp_project(config.test, fn ->
      Gen.Query.run(~w(User users name:string age:integer))
      assert_file("lib/flowy/queries/user_query.ex")
      assert_file("test/flowy/queries/user_query_test.exs")
      assert_file("test/support/fixtures/user_fixtures.ex")

      assert_file("lib/flowy/queries/user_query.ex", fn file ->
        assert file =~ "defmodule Flowy.Queries.UserQuery do"
      end)

      assert_file("test/flowy/queries/user_query_test.exs", fn file ->
        assert file =~ "defmodule Flowy.Queries.UserQueryTest do"
      end)

      assert_file("test/support/fixtures/user_fixtures.ex", fn file ->
        assert file =~ "defmodule Flowy.Tests.Fixtures.UserFixtures do"
      end)
    end)
  end
end
