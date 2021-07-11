defmodule DevhookWeb.WebhookController do
  use DevhookWeb, :controller
  alias DevhookWeb.Endpoint
  alias Devhook.Users
  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook

  @spec post_webhook(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_webhook(conn, %{"webhook_uid" => webhook_uid}) do
    case Webhooks.get_active_webhook(webhook_uid) do
      %Webhook{} = webhook ->
        Endpoint.broadcast("webhooks:" <> webhook_uid, "event:new", build_payload(conn))
        Users.increase_request_count(webhook.user_uid)

        conn
        |> send_resp(200, "ok")

      nil ->
        conn
        |> send_resp(403, "Webhook inactive")
    end
  end

  defp build_payload(conn) do
    %{
      cookies: conn.req_cookies,
      headers: build_headers(conn.req_headers),
      body: conn.body_params,
      metadata: build_metadata(conn)
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

  defp build_metadata(conn) do
    %{
      timestamp: DateTime.utc_now(),
      status: 200,
      method: conn.method,
      request_ip: build_remote_ip(conn.remote_ip)
    }
  end

  defp build_remote_ip({one, two, three, four}) do
    "#{one}.#{two}.#{three}.#{four}"
  end

  defp build_remote_ip({one, two, three, four, five, six, seven, eight}) do
    "#{one}.#{two}.#{three}.#{four}.#{five}.#{six}.#{seven}.#{eight}"
  end
end
