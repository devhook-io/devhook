defmodule Devhook.Webhooks.Subscriptions.FreeWebhook do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :human_name,
             :disabled,
             :destination
           ]}

  @primary_key false

  embedded_schema do
    field :destination, :string
    field :human_name, :string
    field :disabled, :boolean
  end

  @doc false
  def changeset(webhook, attrs) do
    changeset =
      webhook
      |> cast(attrs, [
        :human_name,
        :destination,
        :disabled
      ])
      |> validate_required([:human_name, :destination])

    if changeset.valid? do
      payload = apply_changes(changeset)

      {:ok, payload}
    else
      changeset = %{changeset | action: :free_webhook}
      {:error, changeset}
    end
  end
end
