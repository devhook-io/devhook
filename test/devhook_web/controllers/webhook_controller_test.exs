defmodule DevhookWeb.Controllers.WebhookControllerTest do
  use DevhookWeb.ConnCase, async: true

  import Devhook.Factory

  alias Devhook.Webhooks
  alias Devhook.Users
  alias DevhookWeb.WebhookController

  describe "post_webhook/2" do
    test "Successfully forwards the request to client" do
      webhook = insert(:webhook)
      Webhooks.toggle_webhook(webhook, false)
      conn = build_conn()

      response = WebhookController.post_webhook(conn, %{"webhook_uid" => webhook.uid})
      user = Users.get_user!(webhook.user_uid)

      assert response.status == 200
      assert response.resp_body == ""
      assert user.request_count == 1
    end

    test "Returns a 200 OK when request count is >500 and using developer account" do
      user = insert(:user, request_count: 500, subscription_name: :developer)
      webhook = insert(:webhook, user: user)
      Webhooks.toggle_webhook(webhook, false)
      conn = build_conn()

      response = WebhookController.post_webhook(conn, %{"webhook_uid" => webhook.uid})
      user = Users.get_user!(webhook.user_uid)

      assert response.status == 200
      assert response.resp_body == ""
      assert user.request_count == 501
    end

    test "Returns a 429 error when request count has been reached." do
      user = insert(:user, request_count: 500)
      webhook = insert(:webhook, user: user)
      Webhooks.toggle_webhook(webhook, false)
      conn = build_conn()

      response = WebhookController.post_webhook(conn, %{"webhook_uid" => webhook.uid})

      assert response.status == 429
      assert response.resp_body == "Request limit reached. Please upgrade your account."
    end

    test "Returns a custom body response when account is pro" do
      user = insert(:user, subscription_name: :professional)
      webhook = insert(:webhook, user: user, response: %{"accepted" => true})
      Webhooks.toggle_webhook(webhook, false)
      conn = build_conn()

      response = WebhookController.post_webhook(conn, %{"webhook_uid" => webhook.uid})

      assert response.status == 200
      assert response.resp_body == "{\"accepted\":true}"
    end
  end
end
