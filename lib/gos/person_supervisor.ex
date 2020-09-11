defmodule Gos.PersonSupervisor do
  use Supervisor
  alias Gos.Person

  def start_link(n) do
    Supervisor.start_link(__MODULE__, n, name: __MODULE__)
  end

  @impl true
  def init(n) do
    children =
      0..(n-1)
      |> Enum.map(fn(idx) ->
        Supervisor.child_spec({Person, [idx, n]}, id: idx)
      end)
      |> Enum.reverse() # make life easier by matching idx to index in child spec list.
    Supervisor.init(children, strategy: :one_for_one)
  end

  ##
  ## Helpers
  ##

  def ring_neighbour_pids(idx) do
    children = Supervisor.which_children(__MODULE__)
    right_idx = rem(idx+1, length(children))
    left_idx = case idx-1 do
      idxl when idxl < 0 -> length(children)+idxl
      idxl -> idxl
    end
    {^left_idx, left_pid, _, _} = Enum.at(children, left_idx)
    {^right_idx, right_pid, _, _} = Enum.at(children, right_idx)
    {left_pid, right_pid}
  end

  def check() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn({idx, pid, _, _}) -> {idx, Person.get_secrets(pid) |> unwrap!()} end)
    |> Enum.into(%{})
  end


  defp unwrap!({:ok, v}), do: v
  defp unwrap!({:error, r}), do: raise "error=#{inspect r}"

end



