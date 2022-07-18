defmodule DevhookWeb.TestController do
  use DevhookWeb, :controller

  def index(conn, params) do
    IO.inspect(params)
    conn
    |> send_resp(200, "ok")
  end
end
