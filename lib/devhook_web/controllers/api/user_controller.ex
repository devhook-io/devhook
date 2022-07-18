defmodule DevhookWeb.Api.UserController do
  use DevhookWeb, :controller

  alias Devhook.Users

  def create_user(conn, params) do
    with {:ok, customer} <- Stripe.Customer.create(%{email: params["email"]}),
         params <- Map.put(params, "stripe_customer_id", customer.id),
         {:ok, user} <- Users.create_user(params) do
      json(conn, user)
    else
      {:error, _} -> conn |> send_resp(400, "error creating user")
    end
  end
end
