defmodule Devhook.Repo.Migrations.AlterWebhooksTable do
  use Ecto.Migration

  def change do
    alter table("webhooks") do
      add :response, :map, default: %{}
      add :always_accept, :boolean, deafult: false
    end
  end
end
