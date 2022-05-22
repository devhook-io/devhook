defmodule DevhookWeb.Stripe.WebhookHandler do
  alias Devhook.Users
  alias Devhook.Users.User

  def process(event) do
    handle_event(event.type, event)
    {:ok, :accepted}
  end

  def handle_event("invoice.paid", event) do
    user = Users.get_user_by_stripe_customer_id(event.data.object.customer)
    Users.update_user(user, %{subscription_status: "active"})
  end

  def handle_event("invoice.payment_succeeded", event) do
    if event.data.object.billing_reason == "subscription_create" do
      set_default_payment_method(event)
    end
  end

  def handle_event("invoice.payment_failed", event) do
    event
  end

  def handle_event("customer.subscription.created", event) do
    with "active" <- event.data.object.status,
    %User{} = user <- Users.get_user_by_stripe_customer_id(event.data.object.customer) do
      activate_subscription(user, event)
    end
  end

  def handle_event("customer.subscription.updated", event) do
    with "active" <- event.data.object.status,
    %User{} = user <- Users.get_user_by_stripe_customer_id(event.data.object.customer) do
      activate_subscription(user, event)
    end
  end

  def handle_event("customer.subscription.deleted", event), do: event

  def handle_event(_, event), do: event

  defp activate_subscription(user, event) do
    if event.data.object.plan.product === developer_product_id() do
      Users.update_user(user, %{subscription_name: "developer"})
    else
      Users.update_user(user, %{subscription_name: "professional"})
    end
  end

  defp developer_product_id(), do: System.get_env("STRIPE_DEVELOPER_PRODUCT_ID")
  # defp professional_product_id(), do: System.get_env("STRIPE_PROFESSIONAL_PRODUCT_ID")

  defp set_default_payment_method(event) do
    subscription_id = event.data.object.subscription
    payment_intent_id = event.data.object.payment_intent
    {:ok, payment_intent} = Stripe.PaymentIntent.retrieve(payment_intent_id, %{})

    Stripe.Subscription.update(subscription_id, %{
      default_payment_method: payment_intent.payment_method
    })
  end
end
