defmodule DevhookWeb.WebhooksChannel do
  use DevhookWeb, :channel

  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook

  def join("webhooks:" <> webhook_uid, _params, socket) do
    case Webhooks.get_auth_webhook(webhook_uid, socket.assigns.current_user.uid) do
      %Webhook{} = webhook ->
        socket = assign(socket, :webhook, webhook)
        response = %{webhook: webhook}
        Webhooks.toggle_webhook(webhook, false)
        {:ok, response, socket}

      nil ->
        {:error, "not authorized"}
    end
  end

  def leave(socket, _topic) do
    socket
  end

  def terminate(reason, socket) do
    case reason do
      {:shutdown, :left} ->
        webhook = socket.assigns.webhook
        Webhooks.toggle_webhook(webhook, true)
        assign(socket, :webhook, nil)

      _ ->
        socket
    end
  end
end
