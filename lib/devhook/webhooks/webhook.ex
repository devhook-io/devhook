defmodule Devhook.Webhooks.Webhook do
  use Ecto.Schema
  import Ecto.Changeset
  alias Devhook.Users.User

  @derive {Jason.Encoder,
           only: [
             :allowed_origins,
             :destination,
             :human_name,
             :disabled,
             :uid,
             :response,
             :always_accept
           ]}
  @primary_key {:uid, :binary_id, autogenerate: true}

  schema "webhooks" do
    belongs_to(:user, User,
      foreign_key: :user_uid,
      references: :uid,
      type: :binary_id
    )

    field :allowed_origins, {:array, :string}, default: []
    field :destination, :string
    field :human_name, :string
    field :disabled, :boolean, default: true
    field :response, :map, default: %{}
    field :always_accept, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [
      :human_name,
      :allowed_origins,
      :disabled,
      :destination,
      :user_uid,
      :response,
      :always_accept
    ])
    |> validate_required([:human_name, :destination])
  end
end
