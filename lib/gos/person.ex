defmodule Gos.Person do
  use GenServer
  require Logger

  alias Gos.PersonSupervisor

  defstruct [
    n: nil,
    idx: nil,
    left: nil,
    right: nil,
    secrets: nil,
  ] 

  ##
  ## API
  ##

  def start_link([idx,n]) do
    GenServer.start_link(__MODULE__, [idx,n])
  end

  def gossip_right(pid) do
    GenServer.call(pid, :gossip_right)
  end

  def get_secrets(pid) do
    GenServer.call(pid, :get_secrets)
  end

  def get_idx(pid) do
    GenServer.call(pid, :get_idx)
  end

  def put_secrets(pid, secrets) do
    :telemetry.execute([:person, :put_secrets], %{}, %{from: self(), to: pid, secrets: secrets})
    GenServer.cast(pid, {:put_secrets, secrets})
  end

  ##
  ## GenServer callbacks
  ##

  @impl true
  def init([idx, n]) do
    {:ok, nil, {:continue, [idx, n]}}
  end

  @impl true
  def handle_continue([idx, n], nil) do
    # we do this in continue since otherwise we'd block the PersonSupervisor trying to start us.
    # We can ask the PersonSupervisor for neighbours and just wait for a result since it won't reply
    # before it has started all it's children and therefore know who is neighbour to who.
    {left, right} = PersonSupervisor.ring_neighbour_pids(idx)
    # The secrets we start out knowing (just our own)
    secrets = [{:secret, idx}]
    # if we are index 0 we start a chain of updates:
    {:noreply, %__MODULE__{n: n, idx: idx, left: left, right: right, secrets: secrets}}
  end

  @impl true
  def handle_call(:gossip_right, _from, %{secrets: secrets, right: right}=state) do
    __MODULE__.put_secrets(right, secrets)
    {:reply, :ok, state}
  end
  def handle_call(:get_secrets, _from, state) do
    # lol, state secrets... 
    {:reply, {:ok, state.secrets}, state}
  end
  def handle_call(:get_idx, _from, state) do
    {:reply, {:ok, state.idx}, state}
  end

  @impl true
  def handle_cast({:put_secrets, new}, %{secrets: known, right: right}=state) do
    case Enum.uniq(new ++ known) |> Enum.sort() do
      ^known ->
        # we already knew everything, so we don't cascade right.
        {:noreply, state}
      merged ->
        # new information received, pass it along to the right.
        :ok = __MODULE__.put_secrets(right, merged)
        {:noreply, %{state | secrets: merged}}
    end
  end

end