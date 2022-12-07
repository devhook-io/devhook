defmodule DevhookWeb.WebhookController do
  use DevhookWeb, :controller
  alias DevhookWeb.Endpoint
  alias Devhook.Users
  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook

  @spec post_webhook(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_webhook(conn, %{"webhook_uid" => webhook_uid}) do
    with %Webhook{} = webhook <- Webhooks.get_open_webhook(webhook_uid),
         :ok <- validate_request_count(webhook.user),
         {_, [count]} <- Users.increase_request_count(webhook.user_uid) do
      execute_response(conn, webhook, count)
    else
      :limit_reached ->
        conn
        |> send_resp(429, "Request limit reached. Please upgrade your account.")

      nil ->
        conn
        |> send_resp(403, "Webhook inactive")
    end
  end

  defp build_payload(conn, count) do
    %{
      cookies: conn.req_cookies,
      headers: build_headers(conn.req_headers),
      body: ~s(#{conn.assigns[:raw_body]}),
      metadata: build_metadata(conn, count)
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

  defp build_metadata(conn, count) do
    %{
      timestamp: DateTime.utc_now(),
      status: 200,
      method: conn.method,
      request_ip: build_remote_ip(conn.remote_ip),
      request_count: count
    }
  end

  defp build_remote_ip({one, two, three, four}) do
    "#{one}.#{two}.#{three}.#{four}"
  end

  defp build_remote_ip({one, two, three, four, five, six, seven, eight}) do
    "#{one}.#{two}.#{three}.#{four}.#{five}.#{six}.#{seven}.#{eight}"
  end

  defp send_response(conn, %{user: %{subscription_name: :professional}, response: response}) do
    if response == %{} do
      send_resp(conn, 200, "")
    else
      json(conn, response)
    end
  end

  defp send_response(conn, _webhook) do
     send_resp(conn, 200, "")
  end

  defp execute_response(conn, %{uid: uid, disabled: false} = webhook, count) do
    Endpoint.broadcast("webhooks:" <> uid, "event:new", build_payload(conn, count))

    conn
    |> send_response(webhook)
  end

  defp execute_response(conn, webhook, _count) do
    conn
    |> send_response(webhook)
  end

  defp validate_request_count(%{subscription_name: :free, request_count: request_count}) do
    if request_count < 500 do
      :ok
    else
      :limit_reached
    end
  end

  defp validate_request_count(_user), do: :ok
end
