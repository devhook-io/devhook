defmodule Devhook.Repo.Migrations.AddStripeColumns do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :stripe_customer_id, :string
      add :subscription_status, :string, default: "inactive"
      add :stripe_subscription_id, :string
    end
  end
end
