defmodule IslandsEngine.Game do
  @moduledoc """
  Game process implementation
  """
  use GenServer

  alias IslandsEngine.{Board, Coordinate, Storage, Guesses, Island, Rules}

  @players [:player1, :player2]

  @timeout 15 * 1000

  @doc """
  Creates the "via" tuple to be used by Registry for process name registration
  """
  @spec via_tuple(any) :: {:via, Registry, {Registry.Game, any}}
  def via_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  def child_spec(name) do
    %{
      id: __MODULE__,
      restart: :transient,
      shutdown: 5000,
      start: {__MODULE__, :start_link, [name]},
      type: :worker
    }
  end

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @impl true
  def init(name) do
    send(self(), {:set_state, name})
    {:ok, fresh_state(name)}
  end

  @doc """
  Adds the second player to the game
  """
  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  @doc """
  Position a player's island.

  Until the islands are set, players can position islands as many times as they
  want.
  """
  def position_island(game, player, key, row, col) when player in @players do
    GenServer.call(game, {:position_island, player, key, row, col})
  end

  @doc """
  Mark the players islands as set. After calling this function the game will be
  started and the player1 can start guessing.
  """
  def set_islands(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  @doc """
  Guesses a coordinate from the opponent's board.
  """
  def guess_coordinate(game, player, row, col) when player in @players do
    GenServer.call(game, {:guess_coordinate, player, row, col})
  end

  @impl true
  def terminate(reason, state)

  def terminate({:shutdown, :timeout}, state) do
    Storage.delete(state.player1.name)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  @impl true
  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def handle_info({:set_state, name}, _state) do
    state =
      case Storage.fetch(name) do
        {:error, :not_found} ->
          fresh_state(name)

        {:ok, state} ->
          state
      end

    Storage.store(name, state)

    {:noreply, state, @timeout}
  end

  @impl true
  def handle_call(event, caller_pid, current_state)

  def handle_call({:add_player, name}, _from, state) do
    case Rules.check(state.rules, :add_player) do
      {:ok, rules} ->
        state
        |> update_player2_name(name)
        |> update_rules(rules)
        |> reply_success(:ok)

      :error ->
        {:reply, :error, state, @timeout}
    end
  end

  def handle_call({:position_island, player, key, row, col}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coord} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(key, coord),
         {:ok, board} <- Board.position_island(board, key, island) do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      error ->
        {:reply, error, state, @timeout}
    end
  end

  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board) do
      state
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      false ->
        {:reply, {:error, :not_all_islands_positioned}, state}

      error ->
        {:reply, error, state, @timeout}
    end
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent_key = opponent(player)
    opponent_board = player_board(state, opponent_key)

    with {:ok, rules} <- Rules.check(state.rules, {:guess_coordinate, player}),
         {:ok, coord} <- Coordinate.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coord),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state
      |> update_board(opponent_key, opponent_board)
      |> update_guesses(player, hit_or_miss, coord)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      error ->
        {:reply, error, state, @timeout}
    end
  end

  defp update_player2_name(state, name) do
    put_in(state.player2.name, name)
  end

  defp update_board(state, player, board) do
    Map.update!(state, player, fn p -> %{p | board: board} end)
  end

  defp update_guesses(state, player_key, hit_or_miss, coord) do
    update_in(state[player_key].guesses, fn g ->
      Guesses.add(g, hit_or_miss, coord)
    end)
  end

  defp update_rules(state, rules) do
    %{state | rules: rules}
  end

  defp player_board(state, player) do
    Map.get(state, player).board
  end

  defp opponent(player)
  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp reply_success(state, reply) do
    Storage.store(state.player1.name, state)
    {:reply, reply, state, @timeout}
  end

  defp fresh_state(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}

    %{player1: player1, player2: player2, rules: Rules.new()}
  end
end
