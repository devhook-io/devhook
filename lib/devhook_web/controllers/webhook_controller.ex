defmodule DevhookWeb.WebhookController do
  use DevhookWeb, :controller
  alias DevhookWeb.Endpoint
  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook

  def post_webhook(conn, %{"user_uid" => user_uid, "webhook_uid" => webhook_uid} = params) do
    IO.inspect(params)

    case Webhooks.get_active_auth_webhook(webhook_uid, user_uid) do
      %Webhook{} = _webhook ->
        Endpoint.broadcast("webhooks:" <> webhook_uid, "event:new", build_payload(conn))

        conn
        |> send_resp(200, "ok")

      nil ->
        conn
        |> send_resp(500, "error")
    end
  end

  defp build_payload(conn) do
    %{
      cookies: conn.req_cookies,
      headers: build_headers(conn.req_headers),
      body: conn.body_params
    }
  end

  defp build_headers(headers) do
    headers
    |> Enum.into(%{})
    |> Map.drop([
      "accept-charset",
      "accept-encoding",
      "access-control-request-headers",
      "access-control-request-method",
      "connection",
      "content-length",
      "cookie",
      "cookie2",
      "date",
      "dnt",
      "expect",
      "host",
      "keep-alive",
      "origin",
      "referer",
      "te",
      "trailer",
      "transfer-encoding",
      "upgrade",
      "user-agent",
      "via"
    ])
  end
end
