defmodule DevhookWeb.Api.UserController do
  use DevhookWeb, :controller

  alias Devhook.Users

  def create_user(conn, params) do
    case Users.create_user(params) do
      {:ok, user} -> json(conn, user)
      {:error, _} -> conn |> send_resp(400, "error creating user")
    end
  end
end
