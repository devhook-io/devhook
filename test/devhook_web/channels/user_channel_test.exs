defmodule DevhookWeb.Channels.UserChannelTest do
  use DevhookWeb.ChannelCase
  use ExUnit.Case, async: true

  import Devhook.Factory

  alias Devhook.Webhooks
  alias DevhookWeb.UserSocket
  alias DevhookWeb.UserChannel

  describe "users channel" do
    setup do
      user = insert(:user)

      {:ok, _, socket} =
        socket(UserSocket, "user:#{user.uid}", %{current_user: user})
        |> subscribe_and_join(UserChannel, "user:#{user.uid}", %{})

      [
        user: user,
        socket: socket
      ]
    end

    test "successfully joins the user channel", %{user: user} do
      {:ok, response, _} =
      socket(UserSocket, "user:#{user.uid}", %{current_user: user})
      |> subscribe_and_join(UserChannel, "user:#{user.uid}", %{})

      assert response.user.uid == user.uid
    end

    test "webhooks:new successfully creates webhook", %{socket: socket, user: user} do
      ref = push(socket, "webhooks:new", %{"human_name" => "test webhook", "destination" => "http://localhost:4000/test"})
      assert_reply ref, :ok, [%{human_name: "test webhook"}]
      assert Webhooks.get_all_auth_webhooks(user.uid)
    end

    test "webhooks:update successfully updates webhook", %{socket: socket, user: user} do
      webhook = insert(:webhook, user: user)
      params = %{
        "uid" => webhook.uid,
        "destination" => webhook.destination,
        "human_name" => "new name"
      }
      ref = push(socket, "webhooks:update", params)
      assert_reply ref, :ok, [updated_webhook]

      assert updated_webhook.human_name == "new name"
    end

    test "user:update successfully updates user", %{socket: socket, user: user} do
      ref = push(socket, "user:update", %{"first_name" => "Testy"})
      assert_reply ref, :ok, payload

      assert payload.first_name == "Testy"
      assert payload.last_name == user.last_name
    end
  end
end
