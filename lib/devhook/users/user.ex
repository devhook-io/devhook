defmodule Devhook.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:email, :first_name, :last_name, :uid, :payment_tier, :request_count]}
  @primary_key {:uid, :binary_id, autogenerate: true}

  schema "users" do
    field :auth0_xid, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :payment_tier, :string, default: "free"
    field :request_count, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :auth0_xid, :payment_tier, :request_count])
    |> validate_required([:email, :auth0_xid])
    |> unique_constraint([:email])
  end
end
