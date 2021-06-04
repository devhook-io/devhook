defmodule Devhook.Repo.Migrations.AlterAllowedOrigins do
  use Ecto.Migration

  def change do
    alter table("webhooks") do
      modify :allowed_origins, {:array, :string}, default: []
    end
  end
end
