defmodule DevhookWeb.Channels.WebhooksChannelTest do
  use DevhookWeb.ChannelCase
  use ExUnit.Case, async: true

  import Devhook.Factory

  alias Devhook.Webhooks
  alias DevhookWeb.UserSocket
  alias DevhookWeb.WebhooksChannel

  describe "webhooks channel" do
    setup do
      [
        webhook: insert(:webhook)
      ]
    end

    test "successfully joins the webhooks channel", %{webhook: webhook} do
      {:ok, response, _} =
      socket(UserSocket, "webhooks:#{webhook.uid}", %{current_user: webhook.user})
      |> subscribe_and_join(WebhooksChannel, "webhooks:#{webhook.uid}", %{})

      assert response.webhook.uid == webhook.uid
    end
  end
end
