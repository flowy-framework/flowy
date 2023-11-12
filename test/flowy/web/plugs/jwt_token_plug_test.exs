defmodule Flowy.Web.Plugs.JwtAuthPlugTest do
  use Flowy.ConnCase, async: true
  import Mock

  alias Flowy.Web.Plugs.JwtAuthPlug
  alias Flowy.Support.Http

  describe "call/1" do
    setup do
      System.put_env("OIDC_PUBLIC_KEYS", public_keys_response() |> Jason.encode!())

      start_supervised(Flowy)
      :ok
    end

    @describetag :jwt_auth_plug
    test "returns 403", %{conn: conn} do
      conn = conn |> JwtAuthPlug.call([])

      assert conn.status == 403

      assert conn.resp_body |> Jason.decode!() == %{
               "errors" => [
                 %{
                   "error_code" => "002",
                   "error_message" =>
                     "Forbidden: Something doesn't look quite right. Double check it, will you?"
                 }
               ]
             }
    end

    @tag :jwt_auth_plug_200
    test "returns 200", %{conn: conn} do
      with_mock(Http, get: fn _, _ -> public_keys_response() end) do
        conn =
          conn
          |> Plug.Conn.put_req_header("authorization", "Bearer #{token()}")
          |> Flowy.Web.Plugs.JwtAuthPlug.call(
            aud: "https://flowy.local.dev",
            iss: "https://local.dev/",
            skip: [:exp]
          )

        assert conn.status == nil
      end
    end

    @tag :jwt_auth_plug_403
    test "returns 403 with invalid aud", %{conn: conn} do
      with_mock(Http, get: fn _, _ -> public_keys_response() end) do
        conn =
          conn
          |> Plug.Conn.put_req_header("authorization", "Bearer #{token()}")
          |> Flowy.Web.Plugs.JwtAuthPlug.call(
            iss: "https://hydra.iam.equinixmetal.net/",
            aud: ["https://bouncer.core-a.ny5.random.net"],
            skip: [:exp]
          )

        assert conn.status == 403
      end
    end
  end

  defp public_keys_response() do
    %{
      "keys" => [
        %{
          "p" =>
            "837Qfukg9ihP20UE_Nfx3Yg66mRMQpgupoKneWP6WL639dtXJrskx481bBfhe-WAustmPKe4bsGwdRFpRKV2ZBYGAikCKbUPCTx_I0dTyGscs80ziArOTBtKbD0TsjsPndDV3mLOq0SZ7uk8t6_v0_UKQ7h0nAmJlsIXE0j8QSc",
          "kty" => "RSA",
          "q" =>
            "4srurPxmNxpeuGgYwcrykGDj6p2Z1kscL4NwHl21NF3bkjE3YVGQCH7tUVYcDttISTKxtcIOD8qXRTamKi-gO1YwKbGTPqk1LkCcCBqZp0c7bphtM9Jw07tcU7LVcRzTmWF7xGBF9MobzEs-YSUw-Gd3B6uktO4LFBFul83Szsk",
          "d" =>
            "yLwyWKNMznDmGtH4Jcmb0Ew23QA0n83XQbhMIryZG9zgiy9MALiUz8cajhVmE_p7PPhRCD7Lk3z_RkWMz3RMJ2A4J6W_3cys7phSFSG9xZzuSuWcwIQU4IuWntEVVewovCdNjqjX4y6p94-K46nL4xXrpPQNFm0X529q5paFU2XjC715faz93SNkRr-oveXfqlSp_HJ2z9xzRqeKkdpwvOqHabM_vNfVEbhMxw7AWjaVZjL37xYA-JKtxlUyFROqBRJLWc7LP0ltc0zpoxpFjxJXUAY8Y8VSD0qo8N0DGuf4DC-Ec8ea5MtAR7bXhFaSMOZKiOir9hkFcz6kIBox4Q",
          "e" => "AQAB",
          "use" => "sig",
          "kid" => "UzohT-a5mzKPl0EPhTO4b5ndrvp830DhVPUkpg8JFfs",
          "qi" =>
            "65TqZEnYi9ZbvE2DyBUNTXV0FcX2XBMiCIY-tnZL_vJRt_lIK8XxbyiuQiOCQpkauhbwz2E-XPvzbFls0wgiNn-EOTUtHe2pee4vj6AUGJDteGrhIw96PooB0fHp3Iu_SduBQnlAUw6toj1zgNOJOSq0-M6-3FMnUrjEQEwN_mM",
          "dp" =>
            "gfyO_VEjAYXfq6Sa1wfI3ISfPwWwGFT5gnZ5RTp0KPAXcK5ZRhndtpLi6AOPof6QzCdNOtAmiynnM3fKBJV4MFH5fym5N96qWjnrfT_UoEdeGTZQbi2ml8Zx4npwi1MwMQWNRpzky1Vh_8KPYVgQ5cwIYMKVrb8BrnOKsgbicz0",
          "alg" => "RS256",
          "dq" =>
            "gJDJ_QaYa2RnjeJ1JmcGWxKSIc52ByVNNSItzQkSUD1k29tKqcCzBh3uKs3F2iY1NEmotIDtt8YBOxtf10poazrQ0tH3xu3lV_MIgQ-TS2D2MBv4zAfgLidoj4oxtY3B5pF8uDZbcgmg-I8vLaMHv8nnkFGdbXQEk7vOFgB4IQE",
          "n" =>
            "17b5JP0PLYBtHzBpaUbjig_dHSuFIBsYp8VsxlXVZ2FpxgVaU2s5RC2uO-0LP0c7PmrujGL7DESeWbMYNUPOyPQARKG58ngMZ8FW_ZKwDFXzjq3MqbDSGurh1Ch7rSkoKAd-8BWFBlUZrIohgs-mMKZ929CO1Rm1P_YjCK2qj1z6o3HwcgbNICpbERz4XGpvNFGzcGI-rUGywEeaR_LgTHO24R803DzvU3qTDBCY1g37X7D2JBXMFwu4EcE05abAKvBdlqP4PXGDSyWVaoYiUnolRzN-uqxY8B4XRa12sTO25AnkQn9Q__wqHsq7dK63QM-Nwu39zkm8mbH593qJnw"
        }
      ]
    }
  end

  def token() do
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsInZlcnNpb24iOjYzNn0.eyJpc3MiOiJodHRwczovL2xvY2FsLmRldi8iLCJzdWIiOiJqb2huZG9lQGZsb3d5LmNvbSIsImF1ZCI6Imh0dHBzOi8vZmxvd3kubG9jYWwuZGV2IiwiaWF0IjoxNjk5NzI1Mjg2LCJleHAiOjE2OTk3Mjg3Njh9.BcnCBxO6g5beiDJSCfmcSFErfaAoJRZbVH94D3zy9zjJaSC7DLEfrMqjmv0N7f0YCqfzR5gevnJjdN3_uC1cv6OO6bMfZ4RNc1CnwtXgrgdWp99jyvaVLAhHY5pQ6vQZe4owCxugo-D4Z6ZJeEj-VRVlFodkW2BRMm119FEt17_PpCTaZ_XMkCSdMlfmQ-aLkvBSoa3hp7ERNbiQ37d7aTbfIPlGkVTbQU4hoP5gseZkUKklUH-ubSM7MaF99rkflLX0rNUGMMg4OrTN9oF0R75vjhO8psBvv94C4EhE_1T1cZpdY_bDfj7TEJ8udN8U6HmaTjyKk55lOUAQWU02AA"
  end
end
