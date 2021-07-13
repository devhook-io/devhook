defmodule DevhookWeb.Guardian do
  @moduledoc """
  Our Guardian Context. Initializes Guardian and sets functions used when signing and decoding tokens
  """
  use Guardian, otp_app: :devhook

  alias Devhook.Users

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.auth0_xid)}
  end

  def resource_from_claims(%{"sub" => auth0_xid}) do
    [_, xid] = String.split(auth0_xid, "|")

    case Users.get_user_by_auth0_xid!(xid) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
