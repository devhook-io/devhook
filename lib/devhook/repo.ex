defmodule Devhook.Repo do
  use Ecto.Repo,
    otp_app: :devhook,
    adapter: Ecto.Adapters.Postgres
end
