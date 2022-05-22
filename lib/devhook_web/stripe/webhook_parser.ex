defmodule DevhookWeb.Stripe.WebhookParser do
  @moduledoc """
  Parses webhook requests to verify signatures match, and
  creates a Stripe.Event with the body.
  """

  @behaviour Plug.Parsers

  alias Plug.Conn

  @signature_header "stripe-signature"

  @impl true
  def init(opts), do: opts

  @impl true
  def parse(%Conn{request_path: "/stripe/webhook"} = conn, "application", "json", _headers, opts) do
    with {:ok, signature} <- signature(conn),
         {:ok, body, conn} <- Conn.read_body(conn, opts),
         {:ok, event} <-
           construct_event(body, signature) do
      {:ok, %{"event" => event}, conn}
    else
      _ ->
        {:ok, %{"error" => :unauthenticated}, conn}
    end
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  @spec construct_event(String.t(), String.t()) ::
          {:ok, Stripe.Event.t()} | {:error, :unauthenticated}
  defp construct_event(body, signature) do
    secret = Application.get_env(:stripity_stripe, :signing_secret)

    case Stripe.Webhook.construct_event(body, signature, secret) do
      {:error, _} ->
        {:error, :unauthenticated}

      default ->
        default
    end
  end

  @spec signature(Plug.Conn.t()) :: {:ok, String.t()} | {:error, :unauthenticated}
  defp signature(conn) do
    signature =
      conn
      |> Conn.get_req_header(@signature_header)
      |> List.first()

    if is_nil(signature) do
      {:error, :unauthenticated}
    else
      {:ok, signature}
    end
  end
end
