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
      uid: UUID.generate(),
      user_uid: UUID.generate()
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
      assert Webhooks.list_webhooks() == [webhook]
    end

    test "get_webhook!/1 returns the webhook with given id" do
      webhook = webhook_fixture()
      assert Webhooks.get_webhook!(webhook.id) == webhook
    end

    test "create_webhook/1 with valid data creates a webhook" do
      assert {:ok, %Webhook{} = webhook} = Webhooks.create_webhook(@valid_attrs)
      assert webhook.allowed_origins == []
      assert webhook.destination == "some destination"
      assert webhook.human_name == "some human_name"
    end

    test "create_webhook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Webhooks.create_webhook(@invalid_attrs)
    end

    test "update_webhook/2 with valid data updates the webhook" do
      webhook = webhook_fixture()
      assert {:ok, %Webhook{} = webhook} = Webhooks.update_webhook(webhook, @update_attrs)
      assert webhook.allowed_origins == []
      assert webhook.destination == "some updated destination"
      assert webhook.human_name == "some updated human_name"
    end

    test "update_webhook/2 with invalid data returns error changeset" do
      webhook = webhook_fixture()
      assert {:error, %Ecto.Changeset{}} = Webhooks.update_webhook(webhook, @invalid_attrs)
      assert webhook == Webhooks.get_webhook!(webhook.id)
    end

    test "delete_webhook/1 deletes the webhook" do
      webhook = webhook_fixture()
      assert {:ok, %Webhook{}} = Webhooks.delete_webhook(webhook)
      assert_raise Ecto.NoResultsError, fn -> Webhooks.get_webhook!(webhook.id) end
    end

    test "change_webhook/1 returns a webhook changeset" do
      webhook = webhook_fixture()
      assert %Ecto.Changeset{} = Webhooks.change_webhook(webhook)
    end
  end
end
