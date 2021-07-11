defmodule DevhookWeb.UserChannel do
  use DevhookWeb, :channel

  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook

  def join("user:" <> user_uid, _params, socket) do
    if(user_uid == socket.assigns.current_user.uid) do
      webhooks = Webhooks.get_all_auth_webhooks(user_uid)
      socket = assign(socket, :user, socket.assigns.current_user)
      response = %{user: socket.assigns.current_user, webhooks: webhooks}
      {:ok, response, socket}
    else
      {:error, "not authorized"}
    end
  end

  def handle_in("webhooks:new", payload, socket) do
    payload
    |> Map.put("user_uid", socket.assigns.current_user.uid)
    |> Webhooks.create_webhook()
    |> case do
      {:ok, _} ->
        webhooks = Webhooks.get_all_auth_webhooks(socket.assigns.current_user.uid)
        socket = assign(socket, :user, socket.assigns.current_user)
        {:reply, {:ok, webhooks}, socket}

      {:error, _reason} ->
        {:reply, {:error, "Error creating webhook"}, socket}
    end
  end

  def handle_in("webhooks:update", payload, socket) do
    user_uid = socket.assigns.current_user.uid

    with %Webhook{} = webhook <-
           Webhooks.get_auth_webhook(payload["uid"], user_uid),
         {:ok, _} <- Webhooks.update_webhook(webhook, payload),
         webhooks <- Webhooks.get_all_auth_webhooks(user_uid) do
      socket = assign(socket, :user, socket.assigns.current_user)
      {:reply, {:ok, webhooks}, socket}
    else
      _ ->
        {:reply, {:error, "Error updating webhook"}, socket}
    end
  end
end
