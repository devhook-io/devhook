defmodule DevhookWeb.GuardianErrorHandler do
  @moduledoc """
  Error handler for our Guardian plugs. If any of the Guardian plugs fail it will fallback to this module.
  """
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  @spec auth_error(Plug.Conn.t(), {any(), any()}, Keyword.t()) :: Plug.Conn.t()
  def auth_error(conn, {type, reason}, _opts) do
    body = to_string(type)
    IO.inspect(reason)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, body)
    |> halt()
  end
end
