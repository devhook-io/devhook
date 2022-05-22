defmodule Devhook.Webhooks.Subscriptions.DeveloperWebhook do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :human_name,
             :disabled,
             :destination,
             :allowed_origins
           ]}

  @primary_key false

  schema "developer_webhook" do
    field :destination, :string
    field :human_name, :string
    field :disabled, :boolean
    field :allowed_origins, :string
  end

  @doc false
  def changeset(webhook, attrs) do
    changeset =
      webhook
      |> cast(attrs, [
        :human_name,
        :destination,
        :allowed_origins
      ])
      |> validate_required([:human_name, :destination])

    if changeset.valid? do
      payload = apply_changes(changeset)

      {:ok, payload}
    else
      changeset = %{changeset | action: :developer_webhook}
      {:error, changeset}
    end
  end
end
