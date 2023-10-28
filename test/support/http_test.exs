defmodule Flowy.Support.HttpTest do
  use ExUnit.Case, async: true
  alias Flowy.Support.Http

  doctest Flowy.Support.Http

  describe "build" do
    @describetag :http
    test "build/0" do
      http = Http.build()
      assert http.client == Flowy.Support.Http.FinchClient
      assert http.opts == [{:pool_timeout, 5000}, {:receive_timeout, 15000}]
    end

    test "build/1" do
      http = Http.build(opts: [pool_timeout: 200])
      assert http.client == Flowy.Support.Http.FinchClient
      assert http.opts == [{:receive_timeout, 15000}, {:pool_timeout, 200}]
    end
  end

  describe "get/3" do
    @describetag :http_get
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/posts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == [
                 "application/json; charset=utf-8"
               ]

        Plug.Conn.resp(conn, 200, success_list_response())
      end)

      {:ok, response} =
        Http.get(endpoint_url(bypass.port, "posts"), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 200

      assert response.body == [
               %{"id" => 1, "title" => "Post 1"},
               %{"id" => 2, "title" => "Post 2"},
               %{"id" => 3, "title" => "Post 3"}
             ]
    end

    test "fail", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/posts", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      {:error, response} =
        Http.get(endpoint_url(bypass.port, "posts"), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 500
      assert response.body == "Internal Server Error"
    end
  end

  describe "delete/3" do
    @describetag :http_delete
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "DELETE", "/posts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == [
                 "application/json; charset=utf-8"
               ]

        Plug.Conn.resp(conn, 204, "")
      end)

      {:ok, response} =
        Http.delete(endpoint_url(bypass.port, "posts"), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 204

      assert response.body == ""
    end
  end

  describe "post/3" do
    @describetag :http_post
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/posts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == [
                 "application/json; charset=utf-8"
               ]

        Plug.Conn.resp(conn, 201, success_post_response())
      end)

      {:ok, response} =
        Http.post(endpoint_url(bypass.port, "posts"), Jason.decode!(success_post_response()), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 201
      assert response.body == %{"id" => 1, "title" => "Post 1"}
    end
  end

  describe "put/3" do
    @describetag :http_put
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PUT", "/posts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == [
                 "application/json; charset=utf-8"
               ]

        Plug.Conn.resp(conn, 200, success_post_response())
      end)

      {:ok, response} =
        Http.put(endpoint_url(bypass.port, "posts"), Jason.decode!(success_post_response()), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 200
      assert response.body == %{"id" => 1, "title" => "Post 1"}
    end

    test "success patch", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/posts", fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == [
                 "application/json; charset=utf-8"
               ]

        Plug.Conn.resp(conn, 200, success_post_response())
      end)

      {:ok, response} =
        Http.patch(endpoint_url(bypass.port, "posts"), Jason.decode!(success_post_response()), [
          {"content-type", "application/json; charset=utf-8"}
        ])

      assert response.http_code == 200
      assert response.body == %{"id" => 1, "title" => "Post 1"}
    end
  end

  defp success_post_response() do
    """
    {
      "id": 1,
      "title": "Post 1"
    }
    """
  end

  defp success_list_response() do
    """
    [
      {
        "id": 1,
        "title": "Post 1"
      },
      {
        "id": 2,
        "title": "Post 2"
      },
      {
        "id": 3,
        "title": "Post 3"
      }
    ]
    """
  end

  defp endpoint_url(port, path), do: "http://localhost:#{port}/#{path}"
end
