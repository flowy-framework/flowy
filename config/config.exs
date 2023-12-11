import Config

config :flowy, :oauth,
  site: "https://hydra.mysite.net",
  clients: []

# config :your_app, :flowy,
#   http: [
#     client: Flowy.Support.Http.FinchClient,
#     settings: [
#       receive_timeout: 15_000,
#       pool_timeout: 5_000
#     ]
#   ],
#   service: [
#     keys_format: :snake_case,
#     codes: [
#       "403": %{
#         code: "002",
#         description: "Forbidden: Something doesn't look quite right. Double check it, will you?"
#       }
#     ]
#   ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

if Mix.env() == :test do
  import_config "test.exs"
end

config :ueberauth, Ueberauth,
  base_path: "/oauth",
  providers: [
    okta: {
      Ueberauth.Strategy.Okta,
      [
        oauth2_params: [scope: "openid email profile groups", audience: "api://default"]
      ]
    }
  ]
