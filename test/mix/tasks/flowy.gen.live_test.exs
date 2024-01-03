Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Phx.Gen.LiveTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Flowy.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  defp in_tmp_live_project(test, func) do
    in_tmp_project(test, fn ->
      File.mkdir_p!("lib")
      File.touch!("lib/flowy_web.ex")
      File.touch!("lib/flowy.ex")
      func.()
    end)
  end

  defp in_tmp_live_umbrella_project(test, func) do
    in_tmp_umbrella_project(test, fn ->
      File.mkdir_p!("flowy/lib")
      File.mkdir_p!("flowy_web/lib")
      File.touch!("flowy/lib/flowy.ex")
      File.touch!("flowy_web/lib/flowy_web.ex")
      func.()
    end)
  end

  test "invalid mix arguments", config do
    in_tmp_live_project(config.test, fn ->
      assert_raise Mix.Error, ~r/Expected the core, "blog", to be a valid module name/, fn ->
        Gen.Live.run(~w(blog Post posts title:string))
      end

      assert_raise Mix.Error, ~r/Expected the schema, "posts", to be a valid module name/, fn ->
        Gen.Live.run(~w(Post posts title:string))
      end

      assert_raise Mix.Error, ~r/The core and schema should have different names/, fn ->
        Gen.Live.run(~w(Blog Blog blogs))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Live.run(~w(Blog.Post posts))
      end

      assert_raise Mix.Error, ~r/Invalid arguments/, fn ->
        Gen.Live.run(~w(Blog Post))
      end
    end)
  end

  test "generates live resource and handles existing contexts", config do
    in_tmp_live_project(config.test, fn ->
      Gen.Live.run(~w(Posts Post posts title slug:unique votes:integer cost:decimal
                      tags:array:text popular:boolean drafted_at:datetime
                      status:enum:unpublished:published:deleted
                      published_at:utc_datetime
                      published_at_usec:utc_datetime_usec
                      deleted_at:naive_datetime
                      deleted_at_usec:naive_datetime_usec
                      alarm:time
                      alarm_usec:time_usec
                      secret:uuid:redact announcement_date:date alarm:time
                      metadata:map
                      weight:float user_id:references:users))

      assert_file("lib/flowy/core/posts.ex")
      assert_file("lib/flowy/queries/post_query.ex")
      assert_file("lib/flowy/schemas/post.ex")
      assert_file("test/flowy/core/posts_test.exs")
      assert_file("test/flowy/queries/post_query_test.exs")

      assert_file("lib/flowy_web/live/post_live/index.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.PostLive.Index"
      end)

      assert_file("lib/flowy_web/live/post_live/show.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.PostLive.Show"
      end)

      assert_file("lib/flowy_web/live/post_live/form_component.ex", fn file ->
        assert file =~ "defmodule FlowyWeb.PostLive.FormComponent"
      end)

      assert [path] = Path.wildcard("priv/repo/migrations/*_create_posts.exs")

      assert_file(path, fn file ->
        assert file =~ "create table(:posts)"
        assert file =~ "add :title, :string"
        assert file =~ "create unique_index(:posts, [:slug])"
      end)

      assert_file("lib/flowy_web/live/post_live/index.html.heex", fn file ->
        assert file =~ ~S|~p"/posts"|
      end)

      assert_file("lib/flowy_web/live/post_live/show.html.heex", fn file ->
        assert file =~ ~S|~p"/posts"|
      end)

      assert_file("lib/flowy_web/live/post_live/form_component.ex", fn file ->
        assert file =~ ~s(<.simple_form)
        assert file =~ ~s(<.text field={@form[:title]} type="text")
        assert file =~ ~s(<.text field={@form[:votes]} type="number")
        assert file =~ ~s(<.text field={@form[:cost]} type="number" label="Cost" step="any")

        assert file =~ """
                       <.text
                         field={@form[:tags]}
                         type="select"
                         multiple
               """

        assert file =~ ~s(<.text field={@form[:popular]} type="checkbox")
        assert file =~ ~s(<.text field={@form[:drafted_at]} type="datetime-local")
        assert file =~ ~s(<.text field={@form[:published_at]} type="datetime-local")
        assert file =~ ~s(<.text field={@form[:deleted_at]} type="datetime-local")
        assert file =~ ~s(<.text field={@form[:announcement_date]} type="date")
        assert file =~ ~s(<.text field={@form[:alarm]} type="time")
        assert file =~ ~s(<.text field={@form[:secret]} type="text" label="Secret" />)
        refute file =~ ~s(<field={@form[:metadata]})

        assert file =~ """
                       <.text
                         field={@form[:status]}
                         type="select"
               """

        assert file =~ ~s|Ecto.Enum.values(Flowy.Schemas.Post, :status)|

        refute file =~ ~s(<.text field={@form[:user_id]})
      end)

      assert_file("test/flowy_web/live/post_live_test.exs", fn file ->
        assert file =~ ~r"@invalid_attrs.*popular: false"
        assert file =~ ~S|~p"/posts"|
        assert file =~ ~S|~p"/posts/new"|
        assert file =~ ~S|~p"/posts/#{post}"|
        assert file =~ ~S|~p"/posts/#{post}/show/edit"|
      end)
    end)
  end

  test "with --no-core skips context and schema file generation", config do
    in_tmp_live_project(config.test, fn ->
      Gen.Live.run(~w(Posts Post posts title:string --no-core))

      refute_file("lib/flowy/core/posts.ex")
      refute_file("lib/flowy/schemas/post.ex")
      assert Path.wildcard("priv/repo/migrations/*.exs") == []

      assert_file("lib/flowy_web/live/post_live/index.ex")
      assert_file("lib/flowy_web/live/post_live/show.ex")
      assert_file("lib/flowy_web/live/post_live/form_component.ex")

      assert_file("lib/flowy_web/live/post_live/index.html.heex")
      assert_file("lib/flowy_web/live/post_live/show.html.heex")
      assert_file("test/flowy_web/live/post_live_test.exs")
    end)
  end

  test "with --no-schema skips schema file generation", config do
    in_tmp_live_project(config.test, fn ->
      Gen.Live.run(~w(Posts Post posts title:string --no-schema))

      assert_file("lib/flowy/core/posts.ex")
      refute_file("lib/flowy/schemas/post.ex")
      assert Path.wildcard("priv/repo/migrations/*.exs") == []

      assert_file("lib/flowy_web/live/post_live/index.ex")
      assert_file("lib/flowy_web/live/post_live/show.ex")
      assert_file("lib/flowy_web/live/post_live/form_component.ex")

      assert_file("lib/flowy_web/live/post_live/index.html.heex")
      assert_file("lib/flowy_web/live/post_live/show.html.heex")
      assert_file("test/flowy_web/live/post_live_test.exs")
    end)
  end

  test "with --no-core does not emit warning when context exists", config do
    in_tmp_live_project(config.test, fn ->
      Gen.Live.run(~w(Posts Post posts title:string))

      assert_file("lib/flowy/core/posts.ex")
      assert_file("lib/flowy/queries/post_query.ex")
      assert_file("lib/flowy/schemas/post.ex")

      Gen.Live.run(~w(Posts Comment comments title:string --no-core))
      refute_received {:mix_shell, :info, ["You are generating into an existing context" <> _]}

      assert_file("lib/flowy_web/live/comment_live/index.ex")
      assert_file("lib/flowy_web/live/comment_live/show.ex")
      assert_file("lib/flowy_web/live/comment_live/form_component.ex")

      assert_file("lib/flowy_web/live/comment_live/index.html.heex")
      assert_file("lib/flowy_web/live/comment_live/show.html.heex")
      assert_file("test/flowy_web/live/comment_live_test.exs")
    end)
  end

  test "when more than 50 attributes are given", config do
    in_tmp_live_project(config.test, fn ->
      long_attribute_list = Enum.map_join(0..55, " ", &"attribute#{&1}:string")
      Gen.Live.run(~w(Posts Post posts title #{long_attribute_list}))

      assert_file("test/flowy/core/posts_test.exs", fn file ->
        refute file =~ "...}"
      end)

      assert_file("test/flowy_web/live/post_live_test.exs", fn file ->
        refute file =~ "...}"
      end)
    end)
  end

  describe "inside umbrella" do
    test "without context_app generators config uses web dir", config do
      in_tmp_live_umbrella_project(config.test, fn ->
        File.cd!("flowy_web")

        Application.put_env(:phoenix, :generators, context_app: nil)
        Gen.Live.run(~w(Users User users name:string))

        assert_file("lib/flowy/core/users.ex")
        assert_file("lib/flowy/schemas/user.ex")

        assert_file("lib/flowy_web/live/user_live/index.ex", fn file ->
          assert file =~ "defmodule FlowyWeb.UserLive.Index"
          assert file =~ "use FlowyWeb, :live_view"
        end)

        assert_file("lib/flowy_web/live/user_live/show.ex", fn file ->
          assert file =~ "defmodule FlowyWeb.UserLive.Show"
          assert file =~ "use FlowyWeb, :live_view"
        end)

        assert_file("lib/flowy_web/live/user_live/form_component.ex", fn file ->
          assert file =~ "defmodule FlowyWeb.UserLive.FormComponent"
          assert file =~ "use FlowyWeb, :live_component"
        end)

        assert_file("test/flowy_web/live/user_live_test.exs", fn file ->
          assert file =~ "defmodule FlowyWeb.UserLiveTest"
        end)
      end)
    end

    test "raises with false context_app", config do
      in_tmp_live_umbrella_project(config.test, fn ->
        Application.put_env(:flowy, :generators, context_app: false)

        assert_raise Mix.Error, ~r/no context_app configured/, fn ->
          Gen.Live.run(~w(Users User users name:string))
        end
      end)
    end

    # TODO: Fix this test
    # test "with context_app generators config does not use web dir", config do
    #   in_tmp_live_umbrella_project config.test, fn ->
    #     File.mkdir!("another_app")
    #     Application.put_env(:flowy, :generators, context_app: {:another_app, "another_app"})

    #     File.cd!("flowy")

    #     Gen.Live.run(~w(Accounts User users name:string))

    #     assert_file "another_app/lib/another_app/accounts.ex"
    #     assert_file "another_app/lib/another_app/accounts/user.ex"

    #     assert_file "lib/flowy/live/user_live/index.ex", fn file ->
    #       assert file =~ "defmodule Flowy.UserLive.Index"
    #       assert file =~ "use Flowy, :live_view"
    #     end

    #     assert_file "lib/flowy/live/user_live/show.ex", fn file ->
    #       assert file =~ "defmodule Flowy.UserLive.Show"
    #       assert file =~ "use Flowy, :live_view"
    #     end

    #     assert_file "lib/flowy/live/user_live/form_component.ex", fn file ->
    #       assert file =~ "defmodule Flowy.UserLive.FormComponent"
    #       assert file =~ "use Flowy, :live_component"
    #     end

    #     assert_file "test/flowy/live/user_live_test.exs", fn file ->
    #       assert file =~ "defmodule Flowy.UserLiveTest"
    #     end
    #   end
    # end
  end
end
