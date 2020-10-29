defmodule IslandsEngine.BoardTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Board, Island, Coordinate}
  doctest Board

  @sut Board

  describe "new/0" do
    test "creates a new empty board" do
      expected = {:ok, %{}}
      result = @sut.new()
      assert result == expected
    end
  end

  describe "position_island/3" do
    test "adds an island and return the updated board in an ok tuple" do
      board = %{}
      island = island(:square, 3, 3)

      expected =
        {:ok,
         %{
           square: island
         }}

      result = @sut.position_island(board, :square, island)

      assert result == expected
    end

    test "returns an error if the island overlaps with an existing island in the board" do
      board = %{
        square: island(:square, 4, 4)
      }

      island = island(:s_shape, 5, 2)

      expected = {:error, :overlapping_island}

      result = @sut.position_island(board, :s_shape, island)

      assert result == expected
    end
  end

  describe "all_islands_positioned?/1" do
    test "returns true if all types of islands exist on the board" do
      board = Island.types() |> Map.new(fn type -> {type, :whatever} end)

      result = @sut.all_islands_positioned?(board)

      assert result == true
    end

    test "returns false if the board does not contains all island types" do
      board = %{square: island(:square, 1, 1), atoll: island(:atoll, 4, 4)}

      result = @sut.all_islands_positioned?(board)

      assert result == false
    end
  end

  describe "guess/2" do
    test "returns a hit tuple when the coordinate hits an island but no player won" do
      board = %{square: island(:square, 1, 1)}
      guess = coord(2, 2)

      expected = {
        :hit,
        :none,
        :no_win,
        put_in(board.square.hit_coordinates, coords([{2, 2}]))
      }

      result = @sut.guess(board, guess)

      assert result == expected
    end

    test "returns a miss tuple when the coordinate does not hit any island" do
      board = %{square: island(:square, 1, 1)}
      guess = coord(3, 2)

      expected = {
        :miss,
        :none,
        :no_win,
        board
      }

      result = @sut.guess(board, guess)

      assert result == expected
    end

    test "returns a hit tuple with a win value when the guess hits the last coordinate" do
      board = %{square: island(:square, 1, 1)}
      board = put_in(board.square.hit_coordinates, coords([{1, 1}, {1, 2}, {2, 1}]))

      guess = coord(2, 2)

      expected = {
        :hit,
        :square,
        :win,
        put_in(board.square.hit_coordinates, board.square.coordinates)
      }

      result = @sut.guess(board, guess)

      assert result == expected
    end
  end

  defp coords(coord_list) do
    coord_list
    |> Enum.map(fn {r, c} -> coord(r, c) end)
    |> MapSet.new()
  end

  defp coord(row, col) do
    {:ok, coord} = Coordinate.new(row, col)
    coord
  end

  defp island(type, row, col) do
    {:ok, coord} = Coordinate.new(row, col)
    {:ok, island} = Island.new(type, coord)
    island
  end
end
