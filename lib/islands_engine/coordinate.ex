defmodule IslandsEngine.Coordinate do
  @moduledoc """
  Coordinate handling
  """

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @typedoc """
  A struct that wraps a {row, col} coordinate value. Both `row` and  `col`
  should have their values within the 1 and 10.
  """
  @type t :: %__MODULE__{
          row: non_neg_integer(),
          col: non_neg_integer()
        }

  @board_range 1..10

  @doc """
  Creates a new coordinate using the values of `row` and `col`, which must
  be defined within the range `@board_range`
  """
  @spec(new(non_neg_integer(), non_neg_integer()) :: {:ok, t()}, {:error, :invalid_coordinate})
  def new(row, col)

  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %__MODULE__{row: row, col: col}}
  end

  def new(_row, _col) do
    {:error, :invalid_coordinate}
  end
end
