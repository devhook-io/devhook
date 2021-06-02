defmodule DevhookWeb.Pipelines.Guardian do
  use Guardian.Plug.Pipeline,
    otp_app: :devhook,
    error_handler: DevhookWeb.GuardianErrorHandler,
    module: DevhookWeb.Guardian

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource
  plug Guardian.Plug.EnsureAuthenticated
end
