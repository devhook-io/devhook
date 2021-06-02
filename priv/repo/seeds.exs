# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
alias Devhook.Repo
alias Devhook.Users.User
alias Devhook.Webhooks.Webhook
alias Ecto.UUID

user_uid = UUID.generate()
#
#     Devhook.Repo.insert!(%Devhook.SomeSchema{})
Repo.insert!(%User{
  first_name: "Sutton",
  uid: user_uid,
  last_name: "May",
  email: "suttonmay5@gmail.com",
  auth0_xid: "60b1336885bfb30069f60253"
})

Repo.insert!(%Webhook{
  human_name: "Test Webhook",
  allowed_origins: [],
  destination: "http://localhost:4000/test",
  disabled: false,
  user_uid: user_uid
})

#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
