defmodule Devhook.WebhooksTest do
  use Devhook.DataCase

  import Devhook.Factory

  alias Devhook.Webhooks
  alias Ecto.UUID

  describe "webhooks" do
    alias Devhook.Webhooks.Webhook

    @valid_attrs %{
      allowed_origins: [],
      destination: "some destination",
      human_name: "some human_name",
      uid: UUID.generate()
    }
    @update_attrs %{
      allowed_origins: [],
      destination: "some updated destination",
      human_name: "some updated human_name",
      uid: UUID.generate()
    }
    @invalid_attrs %{allowed_origins: nil, destination: nil, human_name: nil}

    def webhook_fixture(attrs \\ %{}) do
      {:ok, webhook} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Webhooks.create_webhook()

      webhook
    end

    test "list_webhooks/0 returns all webhooks" do
      webhook = insert(:webhook)
      assert Webhooks.list_webhooks() == [Webhooks.get_webhook!(webhook.uid)]
    end

    test "get_webhook!/1 returns the webhook with given id" do
      webhook = insert(:webhook)
      retrieved_webhook = Webhooks.get_webhook!(webhook.uid)

      assert webhook.uid == retrieved_webhook.uid
      assert webhook.human_name == retrieved_webhook.human_name
    end

    test "create_webhook/1 with valid data creates a webhook" do
      user = insert(:user)
      params = Map.put(@valid_attrs, :user_uid, user.uid)
      assert {:ok, %Webhook{} = webhook} = Webhooks.create_webhook(params)
      assert webhook.allowed_origins == []
      assert webhook.destination == "some destination"
      assert webhook.human_name == "some human_name"
    end

    test "create_webhook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Webhooks.create_webhook(@invalid_attrs)
    end

    test "update_webhook/2 with valid data updates the webhook" do
      webhook = insert(:webhook)
      assert {:ok, %Webhook{} = webhook} = Webhooks.update_webhook(webhook, @update_attrs)
      assert webhook.allowed_origins == []
      assert webhook.destination == "some updated destination"
      assert webhook.human_name == "some updated human_name"
    end

    test "update_webhook/2 with invalid data returns error changeset" do
      webhook = insert(:webhook)
      assert {:error, %Ecto.Changeset{}} = Webhooks.update_webhook(webhook, @invalid_attrs)
      non_updated_webhook = Webhooks.get_webhook!(webhook.uid)

      assert webhook.human_name == non_updated_webhook.human_name
      assert webhook.destination == non_updated_webhook.destination
      assert webhook.allowed_origins == non_updated_webhook.allowed_origins
    end

    test "delete_webhook/1 deletes the webhook" do
      webhook = insert(:webhook)
      assert {:ok, %Webhook{}} = Webhooks.delete_webhook(webhook)
      assert_raise Ecto.NoResultsError, fn -> Webhooks.get_webhook!(webhook.uid) end
    end

    test "change_webhook/1 returns a webhook changeset" do
      webhook = insert(:webhook)
      assert %Ecto.Changeset{} = Webhooks.change_webhook(webhook)
    end

    test "toggle_webhook/2 switches the disabled field" do
      webhook = insert(:webhook)
      {:ok, toggled} = Webhooks.toggle_webhook(webhook, false)

      assert toggled.disabled == false
    end
  end
end
