# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :devhook,
  ecto_repos: [Devhook.Repo]

# Configures the endpoint
config :devhook, DevhookWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3AC7YOLbv28LoQCk9JtbGzpTpI1z6g7eJGqGkEvtF62/AkF5VSnWVw+DA9AdCEPb",
  render_errors: [view: DevhookWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Devhook.PubSub,
  live_view: [signing_salt: "khh8gQpE"]

config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET"),
  signing_secret: System.get_env("STRIPE_SIGNING_SECRET")

config :devhook, DevhookWeb.Guardian,
  allowed_algos: ["HS256"],
  verify_module: Guardian.JWT,
  issuer: "https://devhook.io",
  verify_issuer: false,
  secret_key: System.get_env("AUTH0_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :simple_token_authentication,
  token: "letmein"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
