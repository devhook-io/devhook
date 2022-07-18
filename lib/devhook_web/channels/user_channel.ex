defmodule DevhookWeb.UserChannel do
  use DevhookWeb, :channel

  alias Devhook.Users
  # alias Devhook.Users.User
  alias Devhook.Webhooks
  alias Devhook.Webhooks.Webhook
  alias Devhook.Webhooks.Subscriptions.{FreeWebhook, DeveloperWebhook, ProfessionalWebhook}

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

  def handle_in("user:update", payload, socket) do
    user = socket.assigns.current_user

    with {:ok, payload} <- validate_user_payload(payload, user),
         {:ok, payload} <- decode_response(payload),
         {:ok, user} <- Users.update_user(user, payload) do
      socket = assign(socket, :user, user)
      {:reply, {:ok, user}, socket}
    else
      {:error, "Invalid JSON response"} ->
        {:reply, {:error, "Invalid JSON response"}, socket}

      _ ->
        {:reply, {:error, "Error updating webhook"}, socket}
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

    with %Webhook{user: user} = webhook <-
           Webhooks.get_auth_webhook(payload["uid"], user_uid),
         {:ok, payload} <- validate_webhook_payload(payload, user),
         payload <- Map.from_struct(payload),
         {:ok, payload} <- decode_response(payload),
         {:ok, _} <- Webhooks.update_webhook(webhook, payload),
         webhooks <- Webhooks.get_all_auth_webhooks(user_uid) do
      socket = assign(socket, :user, socket.assigns.current_user)
      {:reply, {:ok, webhooks}, socket}
    else
      {:error, "Invalid JSON response"} ->
        {:reply, {:error, "Invalid JSON response"}, socket}

      _ ->
        {:reply, {:error, "Error updating webhook"}, socket}
    end
  end

  defp validate_user_payload(payload, user) do
    {:ok,
     %{
       first_name: payload["first_name"] || user.first_name,
       last_name: payload["last_name"] || user.last_name
     }}
  end

  defp validate_webhook_payload(payload, %{subscription_name: :free}) do
    FreeWebhook.changeset(%FreeWebhook{}, payload)
  end

  defp validate_webhook_payload(payload, %{subscription_name: :developer}) do
    DeveloperWebhook.changeset(%DeveloperWebhook{}, payload)
  end

  defp validate_webhook_payload(payload, %{subscription_name: :professional}) do
    ProfessionalWebhook.changeset(%ProfessionalWebhook{}, payload)
  end

  defp decode_response(%{"response" => response} = payload) do
    case Jason.decode(response) do
      {:ok, response} -> {:ok, Map.put(payload, "response", response)}
      _ -> {:error, "Invalid JSON response"}
    end
  end

  defp decode_response(payload), do: {:ok, payload}
end
