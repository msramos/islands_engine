defmodule IslandsEngine.Island do
  @moduledoc """
  An island is a set of coordinates that can be placed in a board
  """

  @doc """
  A struct that wraps all the data of an island: its coordinates and its hit_coordinates
  """
  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  alias IslandsEngine.{Coordinate}

  @typedoc """
  A struct that wraps the coordinates of an island and all coordinates that were hit by a player
  """
  @type t :: %__MODULE__{
          coordinates: MapSet.t(Coordinate.t()),
          hit_coordinates: MapSet.t(Coordinate.t())
        }

  @doc """
  Returns all available types of islands
  """
  @spec types :: [:atoll | :dot | :l_shape | :s_shape | :square]
  def types, do: [:atoll, :dot, :l_shape, :s_shape, :square]

  @doc """
  Checks if two islands overlap any of their coordinates - they collide.
  """
  @spec overlaps?(t(), t()) :: boolean
  def overlaps?(%__MODULE__{} = island_a, %__MODULE__{} = island_b) do
    not MapSet.disjoint?(island_a.coordinates, island_b.coordinates)
  end

  @doc """
  Checks wether an island has all of its tiles forested (hit)
  """
  @spec forested?(t()) :: boolean()
  def forested?(%__MODULE__{} = island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  @doc """
  Guesses if a coordinate is inside an island
  """
  @spec guess(t(), Coordinate.t()) :: {:hit, t()} | :miss
  def guess(%__MODULE__{} = island, %Coordinate{} = coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @doc """
  Creates a new island, with the given shape starting from the coordinate `upper_left`
  """
  @spec new(atom(), Coordinate.t()) ::
          {:ok, t()} | {:error, :invalid_coordinate | :invalid_island_shape}
  def new(type, %Coordinate{} = upper_left) do
    with {:ok, offsets} <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %__MODULE__{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end

  defp offsets(:square) do
    {:ok, [{0, 0}, {0, 1}, {1, 0}, {1, 1}]}
  end

  defp offsets(:atoll) do
    {:ok, [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]}
  end

  defp offsets(:dot) do
    {:ok, [{0, 0}]}
  end

  defp offsets(:l_shape) do
    {:ok, [{0, 0}, {1, 0}, {2, 0}, {2, 1}]}
  end

  defp offsets(:s_shape) do
    {:ok, [{0, 1}, {0, 2}, {1, 0}, {1, 1}]}
  end

  defp offsets(_shape), do: {:error, :invalid_island_shape}
end
