defmodule Devhook.Factory do
  @moduledoc """
    Ecto Factories
  """
  use ExMachina.Ecto, repo: Devhook.Repo

  alias Devhook.Users.User
  alias Devhook.Webhooks.Webhook

  def user_factory do
    %User{
      auth0_xid: sequence(:authentication_xid, &"auth_xid_#{&1}"),
      email: sequence(:email, &"dev-#{&1}@example.com"),
      first_name: "Danny",
      last_name: "Dev"
    }
  end

  def webhook_factory do
    %Webhook{
      user: insert(:user),
      human_name: "Application 1",
      destination: "https://localhost:4000/"
    }
  end
end
