defmodule DevhookWeb.TestController do
  use DevhookWeb, :controller

  def index(conn, params) do
    conn
    |> send_resp(200, "ok")
  end
end
