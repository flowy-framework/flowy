Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Flowy.Gen.JsonTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Flowy.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "invalid mix arguments", config do
    in_tmp_project(config.test, fn ->
      assert_raise Mix.Error, ~r/Expected the core, "blog", to be a valid module name/, fn ->
        Gen.Json.run(~w(blog Post posts title:string))
      end

      assert_raise Mix.Error, ~r/Expected the schema, "posts", to be a valid module name/, fn ->
        Gen.Json.run(~w(Post posts title:string))
      end

      assert_raise Mix.Error, ~r/The core and schema should have different names/, fn ->
        Gen.Json.run(~w(Blog Blog blogs))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Json.run(~w(Blog.Post posts))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Json.run(~w(Blog Post))
      end
    end)
  end

  test "generates json resource", config do
    one_day_in_seconds = 24 * 3600

    naive_datetime =
      %{NaiveDateTime.utc_now() | second: 0, microsecond: {0, 6}}
      |> NaiveDateTime.add(-one_day_in_seconds)

    datetime =
      %{DateTime.utc_now() | second: 0, microsecond: {0, 6}}
      |> DateTime.add(-one_day_in_seconds)

    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blog Post posts title slug:unique votes:integer cost:decimal
                     tags:array:text popular:boolean drafted_at:datetime
                     params:map
                     published_at:utc_datetime
                     published_at_usec:utc_datetime_usec
                     deleted_at:naive_datetime
                     deleted_at_usec:naive_datetime_usec
                     alarm:time
                     alarm_usec:time_usec
                     secret:uuid:redact announcement_date:date
                     weight:float user_id:references:users))

      assert_file("lib/flowy/schemas/post.ex")
      assert_file("lib/flowy/core/blog.ex")

      assert_file("test/flowy/core/blog_test.exs", fn file ->
        assert file =~ "use Flowy.DataCase"
      end)

      assert_file("test/flowy_web/controllers/api/post_controller_test.exs", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.PostControllerTest"

        assert file =~ """
                     assert %{
                              "id" => ^id,
                              "alarm" => "14:00:00",
                              "alarm_usec" => "14:00:00.000000",
                              "announcement_date" => "#{Date.add(Date.utc_today(), -1)}",
                              "cost" => "120.5",
                              "deleted_at" => "#{naive_datetime |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601()}",
                              "deleted_at_usec" => "#{NaiveDateTime.to_iso8601(naive_datetime)}",
                              "drafted_at" => "#{datetime |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601()}",
                              "params" => %{},
                              "popular" => true,
                              "published_at" => "#{datetime |> DateTime.truncate(:second) |> DateTime.to_iso8601()}",
                              "published_at_usec" => "#{DateTime.to_iso8601(datetime)}",
                              "secret" => "7488a646-e31f-11e4-aace-600308960662",
                              "slug" => "some slug",
                              "tags" => [],
                              "title" => "some title",
                              "votes" => 42,
                              "weight" => 120.5
                            } = json_response(conn, 200)["data"]
               """
      end)

      assert [_] = Path.wildcard("priv/repo/migrations/*_create_posts.exs")

      assert_file("lib/flowy_web/controllers/fallback_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.FallbackController"
      end)

      assert_file("lib/flowy_web/controllers/api/post_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.PostController"
        assert file =~ "use FlowyWeb, :controller"
        assert file =~ "Posts.get!"
        assert file =~ "Posts.all"
        assert file =~ "Posts.create"
        assert file =~ "Posts.update"
        assert file =~ "Posts.delete"
        assert file =~ ~s|~p"/api/posts|
      end)

      assert_receive {:mix_shell, :info,
                      [
                        """

                        Add the resource to your :api scope in lib/flowy_web/router.ex:

                            resources "/posts", PostController, except: [:new, :edit]
                        """
                      ]}
    end)
  end

  @tag :json_gen_with_existing_core_no_prompt
  test "generates into existing core without prompt with --merge-with-existing-context",
       config do
    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blogs Post posts title))

      assert_file("lib/flowy/core/blogs.ex", fn file ->
        assert file =~ "defdelegate get(id), to: PostQuery"
        assert file =~ "defdelegate last(limit), to: PostQuery"
        assert file =~ "defdelegate get!(id), to: PostQuery"
        assert file =~ "defdelegate update!(model, attrs), to: PostQuery"
        assert file =~ "defdelegate update(model, attrs), to: PostQuery"
        assert file =~ "defdelegate delete(model), to: PostQuery"
        assert file =~ "defdelegate create(attrs), to: PostQuery"
        assert file =~ "defdelegate change(model, attrs \\\\ %{}), to: PostQuery, as: :changeset"
      end)

      Gen.Json.run(~w(Blog Comment comments message:string --merge-with-existing-context))

      refute_received {:mix_shell, :info,
                       ["You are generating into an existing context" <> _notice]}

      assert_file("lib/flowy/core/blog.ex", fn file ->
        assert file =~ "defdelegate all, to: CommentQuery"
        assert file =~ "defdelegate get(id), to: CommentQuery"
        assert file =~ "defdelegate last(limit), to: CommentQuery"
        assert file =~ "defdelegate get!(id), to: CommentQuery"
        assert file =~ "defdelegate update!(model, attrs), to: CommentQuery"
        assert file =~ "defdelegate update(model, attrs), to: CommentQuery"
        assert file =~ "defdelegate delete(model), to: CommentQuery"
        assert file =~ "defdelegate create(attrs), to: CommentQuery"

        assert file =~
                 "defdelegate change(model, attrs \\\\ %{}), to: CommentQuery, as: :changeset"
      end)
    end)
  end

  test "when more than 50 arguments are given", config do
    in_tmp_project(config.test, fn ->
      long_attribute_list = Enum.map_join(0..55, " ", &"attribute#{&1}:string")
      Gen.Json.run(~w(Blog Post posts #{long_attribute_list}))

      assert_file("test/flowy_web/controllers/api/post_controller_test.exs", fn file ->
        refute file =~ "...}"
      end)
    end)
  end

  test "with json --web namespace generates namespaced web modules and directories", config do
    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blog Post posts title:string --web Blog))

      assert_file("test/flowy_web/controllers/api/blog/post_controller_test.exs", fn file ->
        assert file =~ "defmodule FlowyWeb.Blog.Controllers.Api.PostControllerTest"
        assert file =~ ~s|~p"/api/blog/posts|
      end)

      assert_file("lib/flowy_web/controllers/api/blog/post_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Blog.Controllers.Api.PostController"
        assert file =~ "use FlowyWeb, :controller"
        assert file =~ ~s|~p"/api/blog/posts|
      end)

      assert_file("lib/flowy_web/controllers/api/blog/post_json.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Blog.Controllers.Api.PostJSON"
      end)

      assert_file("lib/flowy_web/controllers/changeset_json.ex", fn file ->
        assert file =~ "Ecto.Changeset.traverse_errors(changeset, &translate_error/1"
      end)

      # TODO: We should somehow merge the outputs
      # of the gen tasks into one.
      assert_receive {:mix_shell, :info,
                      [
                        """

                        Add the generated fixture to your test/support/setups.ex file:

                          alias Flowy.Tests.Fixtures.PostFixtures

                          def setup_post(context) do
                            post = PostFixtures.post_fixture()

                            context
                            |> add_to_context(%{post: post})
                          end
                        """
                      ]}
    end)
  end

  @tag :json_with_no_context
  test "with --no-context skips context and schema file generation", config do
    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blog Comment comments title:string --no-core))

      refute_file("lib/flowy/core/blog.ex")
      refute_file("lib/flowy/schemas/comment.ex")
      assert Path.wildcard("priv/repo/migrations/*.exs") == []

      assert_file("test/flowy_web/controllers/api/comment_controller_test.exs", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentControllerTest do"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentController"
        assert file =~ "use FlowyWeb, :controller"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_json.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentJSON"
      end)
    end)
  end

  test "with --no-core no warning is emitted when context exists", config do
    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blog Post posts title:string))

      assert_file("lib/flowy/core/blog.ex")
      assert_file("lib/flowy/schemas/post.ex")

      Gen.Json.run(~w(Blog Comment comments title:string --no-core))
      refute_received {:mix_shell, :info, ["You are generating into an existing core" <> _]}

      assert_file("test/flowy_web/controllers/api/comment_controller_test.exs", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentControllerTest"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentController"
        assert file =~ "use FlowyWeb, :controller"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_json.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentJSON"
      end)
    end)
  end

  test "with --no-schema skips schema file generation", config do
    in_tmp_project(config.test, fn ->
      Gen.Json.run(~w(Blog Comment comments title:string --no-schema))

      assert_file("lib/flowy/core/blog.ex")
      refute_file("lib/flowy/schemas/comment.ex")
      assert Path.wildcard("priv/repo/migrations/*.exs") == []

      assert_file("test/flowy_web/controllers/api/comment_controller_test.exs", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentControllerTest"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_controller.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentController"
        assert file =~ "use FlowyWeb, :controller"
      end)

      assert_file("lib/flowy_web/controllers/api/comment_json.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.Controllers.Api.CommentJSON"
      end)
    end)
  end

  test "with existing core_components.ex file", config do
    in_tmp_project(config.test, fn ->
      File.mkdir_p!("lib/flowy_web/components")

      File.write!("lib/flowy_web/components/core_components.ex", """
      defmodule FlowyWeb.CoreComponents do
      end
      """)

      [{module, _}] = Code.compile_file("lib/flowy_web/components/core_components.ex")

      Gen.Json.run(~w(Blog Post posts title:string --web Blog))

      assert_file("lib/flowy_web/controllers/changeset_json.ex", fn file ->
        assert file =~
                 "Ecto.Changeset.traverse_errors(changeset, &translate_error/1)"
      end)

      # Clean up test case specific compile artifact so it doesn't leak to other test cases
      :code.purge(module)
      :code.delete(module)
    end)
  end
end
