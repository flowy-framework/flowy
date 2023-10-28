defmodule Flowy.Support.OAuthDynamicSupervisorTest do
  use ExUnit.Case
  alias Flowy.Support.OAuth.{OAuthDynamicSupervisor, OAuthServer}
  import Mock

  @client_id "test_client_id"

  describe "OAuth" do
    @describetag :oauth_dynamic_supervisor

    test "starts a child process" do
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
            client_id: "test_client_id",
            client_secret: "test_client_secret",
            audience: "http://test_client",
            site: "http://test_client",
            scopes: [],
            token_url: "/oauth2/token"
          })

        assert child_pid != nil
        assert Process.alive?(child_pid)

        token = OAuthServer.token(@client_id)
        assert token == {:ok, "the_token"}

        DynamicSupervisor.terminate_child(OAuthDynamicSupervisor, child_pid)
      end
    end
  end
end
