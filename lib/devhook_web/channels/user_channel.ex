defmodule DevhookWeb.UserChannel do
  use DevhookWeb, :channel

  alias Devhook.Webhooks

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
end
