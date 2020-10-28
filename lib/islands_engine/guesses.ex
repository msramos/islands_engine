defmodule IslandsEngine.Guesses do
  @moduledoc """
  Guesses handling
  """
  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @typedoc """
  A struct that holds the data of hits and misses of a game
  """
  @type t :: %__MODULE__{
          hits: MapSet.t(Coordinate.t()),
          misses: MapSet.t(Coordinate.t())
        }

  @doc """
  Creates a new empty `Guesses` struct, with no hits nor misses
  """
  @spec new :: IslandsEngine.Guesses.t()
  def new do
    %__MODULE__{hits: MapSet.new(), misses: MapSet.new()}
  end

  @spec add(t(), :hit | :miss, Coordinate.t()) :: t()
  def add(guesses, hit_or_miss, coordinate)

  def add(%__MODULE__{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%__MODULE__{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
