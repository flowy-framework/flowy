defmodule Flowy.Support.OAuthDynamicSupervisorTest do
  use ExUnit.Case
  alias Flowy.Support.OAuth.{OAuthDynamicSupervisor, OAuthServer}
  import Mock

  @client_id "test_client_id"

  describe "OAuth" do
    @describetag :oauth_dynamic_supervisor

    setup(_) do
      start_supervised(OAuthDynamicSupervisor)

      :ok
    end

    @tag :oauth_client
    test "client/0" do
      # Removing settings from the application environment
      Application.put_env(:flowy, :oauth, nil)

      assert OAuthDynamicSupervisor.clients() == []
    end

    test "start_children/1" do
      with_mocks([
        {OAuth2.Client, [],
         [
           new: fn _ -> %OAuth2.Client{} end,
           put_serializer: fn _, _, _ -> %OAuth2.Client{} end,
           get_token!: fn _, _ ->
             %OAuth2.Client{
               token: %OAuth2.AccessToken{
                 access_token: "the_token",
                 refresh_token: "the_refresh_token",
                 expires_at: 3600
               }
             }
           end
         ]}
      ]) do
        {:ok, [{:ok, child_pid}]} =
          OAuthDynamicSupervisor.start_children([
            %{
              client_id: @client_id,
              client_secret: "test_client_secret",
              audience: "http://test_client",
              site: "http://test_client",
              scopes: [],
              token_url: "/oauth2/token"
            }
          ])

        token = OAuthServer.token(@client_id)
        assert token == {:ok, "the_token"}

        DynamicSupervisor.terminate_child(OAuthDynamicSupervisor, child_pid)
      end
    end

    test "start_child/1" do
      with_mocks([
        {OAuth2.Client, [],
         [
           new: fn _ -> %OAuth2.Client{} end,
           put_serializer: fn _, _, _ -> %OAuth2.Client{} end,
           get_token!: fn _, _ ->
             %OAuth2.Client{
               token: %OAuth2.AccessToken{
                 access_token: "the_token",
                 refresh_token: "the_refresh_token",
                 expires_at: 3600
               }
             }
           end
         ]}
      ]) do
        {:ok, child_pid} =
          OAuthDynamicSupervisor.start_child(%{
            client_id: "test_client_id_child",
            client_secret: "test_client_secret",
            audience: "http://test_client",
            site: "http://test_client",
            scopes: [],
            token_url: "/oauth2/token"
          })

        assert child_pid != nil
        assert Process.alive?(child_pid)

        token = OAuthServer.token("test_client_id_child")
        assert token == {:ok, "the_token"}

        DynamicSupervisor.terminate_child(OAuthDynamicSupervisor, child_pid)
      end
    end

    @tag :expired_token
    test "handling expired tokens" do
      with_mocks([
        {OAuth2.Client, [],
         [
           new: fn _ -> %OAuth2.Client{} end,
           put_serializer: fn _, _, _ -> %OAuth2.Client{} end,
           get_token!: fn _, _ ->
             %OAuth2.Client{
               token: %OAuth2.AccessToken{
                 access_token: "the_token",
                 refresh_token: "the_refresh_token",
                 expires_at: 3600
               }
             }
           end
         ]}
      ]) do
        {:ok, child_pid} =
          OAuthDynamicSupervisor.start_child(%{
            client_id: "test_client_id_child",
            client_secret: "test_client_secret",
            audience: "http://test_client",
            site: "http://test_client",
            scopes: [],
            token_url: "/oauth2/token"
          })

        assert child_pid != nil
        assert Process.alive?(child_pid)

        token = OAuthServer.token("test_client_id_child")
        assert token == {:ok, "the_token"}

        token = OAuthServer.token("test_client_id_child")
        assert token == {:ok, "the_token"}

        DynamicSupervisor.terminate_child(OAuthDynamicSupervisor, child_pid)
      end
    end

    @tag :capture_log
    test "start_child/1 with no connection" do
      with_mocks([
        {OAuth2.Client, [],
         [
           new: fn _ -> %OAuth2.Client{} end,
           put_serializer: fn _, _, _ -> %OAuth2.Client{} end,
           get_token!: fn _, _ ->
             raise %OAuth2.Error{reason: :econnrefused}
           end
         ]}
      ]) do
        {:ok, child_pid} =
          start_supervised(
            {Flowy.Support.OAuth.OAuthServer,
             %{
               client_id: "test_client_id_no_conn",
               client_secret: "test_client_secret",
               audience: "http://test_client",
               site: "http://test_client",
               scopes: [],
               token_url: "/oauth2/token"
             }}
          )

        assert child_pid != nil
        assert Process.alive?(child_pid)

        Process.flag(:trap_exit, true)

        assert {{%OAuth2.Error{reason: :econnrefused}, _}, _} =
                 catch_exit(OAuthServer.token("test_client_id_no_conn"))

        # assert_received({:EXIT, _, _})

        # token = OAuthServer.token(@client_id)
        # assert_receive {:EXIT, ^child_pid, _}
        # assert {:error, _} = token
      end
    end
  end
end
