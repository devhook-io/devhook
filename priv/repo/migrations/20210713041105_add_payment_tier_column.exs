defmodule Devhook.Repo.Migrations.AddPaymentTierColumn do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :subscription_name, :string, default: "free"
    end
  end
end
