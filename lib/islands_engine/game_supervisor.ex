defmodule IslandsEngine.GameSupervisor do
  @moduledoc """
  DynamicSupervisor implementation to handle instances of `IslandsEngine.Game`
  processes.
  """
  use DynamicSupervisor

  alias IslandsEngine.{Game, Storage}

  @doc """
  Starts a new GameSupervisor

  See `DynamicSupervisor.start_link/3`
  """
  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Callback implementation

  See `DynamicSupervisor.init/1`
  """
  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new `Islands.Game` under the supervision of this supervisor.
  """
  def start_game(name) do
    spec = {Game, name}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Stops a running `Islands.Game` process and clears its storage
  """
  def stop_game(name) do
    Storage.delete(name)
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
