defmodule DevhookWeb.Stripe.WebhookController do
  use DevhookWeb, :controller

  alias DevhookWeb.Stripe.WebhookHandler

  def handle_webhook(conn, %{"event" => event}) do
    case WebhookHandler.process(event) do
      {:ok, _} ->
        json(conn, %{status: "ok"})

      _ ->
        conn
        |> put_status(400)
        |> json(%{status: "error"})
    end
  end

  def handle_webhook(conn, %{"error" => :unauthenticated}) do
    conn
    |> put_status(401)
    |> json(%{status: "error"})
  end
end
