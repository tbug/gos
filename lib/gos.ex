defmodule Gos do
  @moduledoc """
  Documentation for Gos.
  """
  alias Gos.Person
  alias Gos.PersonSupervisor

  def dump_stats() do
    children = Supervisor.which_children(PersonSupervisor)
    IO.puts("Total N person(s): #{length(children)}\n")

    tab = :put_secret_counters
    fun = fn({pid, counter}, acc) ->
      {:ok, idx} = Person.get_idx(pid)
      {:ok, secrets} = Person.get_secrets(pid)
      IO.puts("Person #{idx} sent #{counter} message(s) and holds #{length(secrets)} secret(s)")
      acc+counter
    end
    total = :ets.foldl(fun, 0, tab)
    IO.puts("\nIn total #{total} message(s)")
  end

  def poke(idx) do
    {^idx, pid, _, _} = Supervisor.which_children(PersonSupervisor) |> Enum.at(idx)
    :ok = Person.gossip_right(pid)    
  end
end
