defmodule Devhook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Devhook.Repo,
      # Start the Telemetry supervisor
      DevhookWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Devhook.PubSub},
      # Start the Endpoint (http/https)
      DevhookWeb.Endpoint,
      # Start a worker by calling: Devhook.Worker.start_link(arg)
      # {Devhook.Worker, arg}
      {Redix, name: :redix}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Devhook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DevhookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
