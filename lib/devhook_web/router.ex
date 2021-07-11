defmodule DevhookWeb.Router do
  use DevhookWeb, :router

  pipeline :browser do
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SimpleTokenAuthentication
  end

  scope "/", DevhookWeb do
    pipe_through :browser

    post "/test", TestController, :index
  end

  scope "/api", DevhookWeb do
    pipe_through :api

    post "/user", Api.UserController, :create_user
  end

  scope "/webhooks", DevhookWeb do
    post "/:webhook_uid", WebhookController, :post_webhook
  end

  # Other scopes may use custom stacks.
  # scope "/api", DevhookWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: DevhookWeb.Telemetry
    end
  end
end
