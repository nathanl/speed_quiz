defmodule SpeedQuiz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SpeedQuizWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SpeedQuiz.PubSub},
      # Start the Endpoint (http/https)
      SpeedQuizWeb.Endpoint
      # Start a worker by calling: SpeedQuiz.Worker.start_link(arg)
      # {SpeedQuiz.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpeedQuiz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpeedQuizWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
