defmodule DevhookWeb.Api.WebhooksController do
  use DevhookWeb, :controller

  alias Devhook.Webhooks

  def get_webhooks(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    webhooks = Webhooks.get_all_auth_webhooks(user.uid)

    json(conn, webhooks)
  end

  def options(conn, _params) do
    conn
    |> send_resp(200, "ok")
  end
end
