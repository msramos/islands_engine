defmodule IslandsEngine.Rules do
  @moduledoc """
  Handles which actions can be applied to a game based on its state
  """
  defstruct state: :initialized, player1: :island_not_set, player2: :island_not_set

  @typedoc """
  A struct that holds the state of a game
  """
  @type t :: %__MODULE__{
          state: atom(),
          player1: atom(),
          player2: atom()
        }

  @typedoc """
  All possible actions to be used with `check/2` function
  """
  @type actions ::
          :add_player
          | {:position_island, :player1 | :player2}
          | {:set_islands, :player1 | :player2}
          | {:guess_coordinate, :player1 | :player2}
          | {:win_check, :win | :no_win}

  @doc """
  Creates a new and empty rules struct
  """
  @spec new :: t()
  def new, do: %__MODULE__{}

  @doc """
  Tries to perform an action based on the current state of the game. If the action is valid, an `{:ok, %Rules{}}` value
  is returned with the updated rule state. If the action is invalid this function will return `:error`
  """
  @spec check(rules :: t(), action :: actions()) :: {:ok, t()} | :error
  def check(rules, action)

  # State change: initialized -> players_set
  def check(%__MODULE__{state: :initialized} = rules, :add_player) do
    {:ok, %__MODULE__{rules | state: :players_set}}
  end

  def check(%__MODULE__{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :island_set -> :error
      :island_not_set -> {:ok, rules}
    end
  end

  # State change: players_set -> player1_turn
  def check(%__MODULE__{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    case both_players_islands_set?(rules) do
      true -> {:ok, %__MODULE__{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  # State change: player1_turn -> player2_turn
  def check(%__MODULE__{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %__MODULE__{rules | state: :player2_turn}}
  end

  # State change: player1_turn -> game_over
  def check(%__MODULE__{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :win ->
        {:ok, %__MODULE__{rules | state: :game_over}}

      :no_win ->
        {:ok, rules}
    end
  end

  # State change: player2_turn -> player1_turn
  def check(%__MODULE__{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %__MODULE__{rules | state: :player1_turn}}
  end

  # State change: player2_turn -> game_over
  def check(%__MODULE__{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :win ->
        {:ok, %__MODULE__{rules | state: :game_over}}

      :no_win ->
        {:ok, rules}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set && rules.player2 == :islands_set
  end
end
