defmodule Devhook.Repo.Migrations.AddInitialSignup do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :initial_signup, :boolean, default: true
    end
  end
end
