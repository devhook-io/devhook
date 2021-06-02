defmodule Devhook.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:uid, :uuid, null: false)
      add :email, :string,  null: false
      add :first_name, :string
      add :last_name, :string
      add :auth0_xid, :string,  null: false

      timestamps()
    end

    create_if_not_exists unique_index(:users, [:uid])
    create_if_not_exists unique_index(:users, [:email])
    create_if_not_exists unique_index(:users, [:auth0_xid])

  end
end
