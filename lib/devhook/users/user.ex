defmodule Devhook.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Devhook.Webhooks.Webhook

  @derive {Jason.Encoder,
           only: [
             :email,
             :first_name,
             :last_name,
             :uid,
             :stripe_customer_id,
             :subscription_status,
             :subscription_name,
             :request_count,
             :initial_signup,
             :stripe_subscription_id
           ]}
  @primary_key {:uid, :binary_id, autogenerate: true}

  schema "users" do
    field :auth0_xid, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string

    field :subscription_name, Ecto.Enum,
      values: [free: "free", developer: "developer", professional: "professional"],
      default: :free

    field :stripe_customer_id, :string
    field :subscription_status, :string, default: "Incomplete"
    field :request_count, :integer, default: 0
    field :initial_signup, :boolean, default: true
    field :stripe_subscription_id, :string

    has_many(:webhoooks, Webhook)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :first_name,
      :last_name,
      :auth0_xid,
      :request_count,
      :initial_signup,
      :stripe_customer_id,
      :subscription_status,
      :subscription_name,
      :stripe_subscription_id
    ])
    |> validate_required([:email, :auth0_xid])
    |> unique_constraint([:email])
  end
end
