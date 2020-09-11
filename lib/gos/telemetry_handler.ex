defmodule Gos.TelemetryHandler do
  require Logger

  def handle_event([:person, :put_secrets], _, %{from: from, to: to, secrets: secrets}, tab) do
    :ets.update_counter(tab, from, 1, {from, 0})
    Logger.debug("person.send from #{inspect from} to #{inspect to} (secrets=#{inspect secrets})")
  end

end
