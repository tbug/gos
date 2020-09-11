defmodule Gos.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Some setup for our telemetry handler is required, but be just dispatch everything to
    # the TelemetryHandler module
    tab = :ets.new(:put_secret_counters, [:set, :public, :named_table])
    :ok = :telemetry.attach_many(
      "log-messages-handler",
      [
        [:person, :put_secrets],
      ],
      &Gos.TelemetryHandler.handle_event/4,
      tab
    )


    # This is the N number of persons we start:
    n = 10
    children = [
      {Gos.PersonSupervisor, n}
    ]
    opts = [strategy: :one_for_one, name: Gos.Supervisor]
    Supervisor.start_link(children, opts)

  end
end
