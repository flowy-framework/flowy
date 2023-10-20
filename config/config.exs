import Config

config :flowy, :oauth,
  site: "https://hydra.mysite.net",
  clients: []

# config :flowy, :cache,
#   store: Flowy.Support.Cache.MemoryStore,
#   settings: [
#     # 5 minutes
#     ttl: 300
#   ]

# config :flowy, :http,
#   client: Flowy.Support.Http.FinchClient,
#   settings: [
#     receive_timeout: 15_000,
#     pool_timeout: 5_000
#   ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
