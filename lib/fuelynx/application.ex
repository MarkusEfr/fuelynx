defmodule Fuelynx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FuelynxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fuelynx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Fuelynx.PubSub},
      # Start a worker by calling: Fuelynx.Worker.start_link(arg)
      # {Fuelynx.Worker, arg},
      # Start to serve requests, typically the last entry
      FuelynxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fuelynx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FuelynxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
