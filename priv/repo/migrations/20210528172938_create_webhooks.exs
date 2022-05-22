defmodule Devhook.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks) do
      add(:uid, :uuid, null: false)
      add :human_name, :string, null: false
      add :allowed_origins, {:array, :string}
      add :destination, :string, null: false
      add :disabled, :boolean, default: true

      add(
        :user_uid,
        references(:users, column: :uid, type: :uuid, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    create_if_not_exists unique_index(:webhooks, [:uid])
  end
end
