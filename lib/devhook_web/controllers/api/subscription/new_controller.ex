defmodule DevhookWeb.Api.Subscription.NewController do
  @moduledoc """
  This controller handles all new customer signups with Stripe. It will create a subscription for that user.
  """
  use DevhookWeb, :controller

  alias Devhook.Users

  def create_subscription(conn, %{"priceId" => nil}) do
    {:ok, user} =
      conn
      |> Guardian.Plug.current_resource()
      |> Users.update_user(%{subscription_name: :free, initial_signup: false})

    json(conn, user)
  end

  def create_subscription(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    payload = %{
      customer: user.stripe_customer_id,
      payment_behavior: "default_incomplete",
      expand: ["latest_invoice.payment_intent"],
      items: [%{price: params["priceId"]}]
    }

    {:ok, subscription} = Stripe.Subscription.create(payload)

    Users.update_user(user, %{
      initial_signup: false,
      stripe_subscription_id: subscription.id,
      stripe_subscription_status: subscription.status
    })

    json(conn, %{
      subscriptionId: subscription.id,
      clientSecret: subscription.latest_invoice.payment_intent.client_secret
    })
  end
end
