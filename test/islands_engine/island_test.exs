defmodule IslandsEngine.IslandTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Coordinate, Island}
  doctest Island

  @sut Island

  describe "types/0" do
    test "returns all available island types" do
      expected = [:atoll, :dot, :l_shape, :s_shape, :square]

      result = @sut.types()

      assert result == expected
    end
  end

  describe "overlaps?/2" do
    test "returns true when two islands overlap each other" do
      island_a = %Island{
        coordinates: coords!([{5, 4}, {6, 5}]),
        hit_coordinates: MapSet.new()
      }

      island_b = %Island{
        coordinates: coords!([{4, 3}, {5, 4}]),
        hit_coordinates: MapSet.new()
      }

      result = @sut.overlaps?(island_a, island_b)

      assert result == true
    end

    test "returns false when two islands do not overlap each other" do
      island_a = %Island{
        coordinates: coords!([{5, 4}, {6, 5}]),
        hit_coordinates: MapSet.new()
      }

      island_b = %Island{
        coordinates: coords!([{5, 5}, {6, 4}]),
        hit_coordinates: MapSet.new()
      }

      result = @sut.overlaps?(island_a, island_b)

      assert result == false
    end
  end

  describe "forested?/1" do
    test "returns true if all of the island hit_coordinates are the same as its coordinates" do
      island = %Island{
        coordinates: coords!([{5, 4}, {6, 5}]),
        hit_coordinates: coords!([{5, 4}, {6, 5}])
      }

      result = @sut.forested?(island)

      assert result == true
    end

    test "returns false if not all of the island hit_coordinates are the same as its coordinates" do
      island = %Island{
        coordinates: coords!([{5, 4}, {6, 6}]),
        hit_coordinates: coords!([{5, 4}, {6, 5}])
      }

      result = @sut.forested?(island)

      assert result == false
    end
  end

  describe "guess/2" do
    test "returns {:hit, %Island{}} if a coordinate has hit the island" do
      island = %Island{
        coordinates: coords!([{5, 4}, {6, 6}]),
        hit_coordinates: MapSet.new()
      }

      expected =
        {:hit,
         %Island{
           coordinates: coords!([{5, 4}, {6, 6}]),
           hit_coordinates: coords!([{5, 4}])
         }}

      guess = coord!(5, 4)

      result = @sut.guess(island, guess)

      assert result == expected
    end

    test "returns :miss if a coordinate did not hit the island" do
      island = %Island{
        coordinates: coords!([{5, 4}, {6, 6}]),
        hit_coordinates: MapSet.new()
      }

      expected = :miss

      guess = coord!(5, 5)

      result = @sut.guess(island, guess)

      assert result == expected
    end
  end

  describe "new/2" do
    test "creates a square island" do
      upper_left = coord!(1, 1)

      expected =
        {:ok,
         %Island{
           coordinates: coords!([{1, 1}, {1, 2}, {2, 1}, {2, 2}]),
           hit_coordinates: MapSet.new()
         }}

      result = @sut.new(:square, upper_left)

      assert result == expected
    end

    test "creates a dot island" do
      upper_left = coord!(1, 1)

      expected =
        {:ok,
         %Island{
           coordinates: coords!([{1, 1}]),
           hit_coordinates: MapSet.new()
         }}

      result = @sut.new(:dot, upper_left)

      assert result == expected
    end

    test "creates a l-shape island" do
      upper_left = coord!(1, 1)

      expected =
        {:ok,
         %Island{
           coordinates: coords!([{1, 1}, {2, 1}, {3, 1}, {3, 2}]),
           hit_coordinates: MapSet.new()
         }}

      result = @sut.new(:l_shape, upper_left)

      assert result == expected
    end

    test "creates a s-shape island" do
      upper_left = coord!(1, 1)

      expected =
        {:ok,
         %Island{
           coordinates: coords!([{2, 1}, {2, 2}, {1, 2}, {1, 3}]),
           hit_coordinates: MapSet.new()
         }}

      result = @sut.new(:s_shape, upper_left)

      assert result == expected
    end

    test "creates an atoll island" do
      upper_left = coord!(1, 1)

      expected =
        {:ok,
         %Island{
           coordinates: coords!([{1, 1}, {1, 2}, {2, 2}, {3, 1}, {3, 2}]),
           hit_coordinates: MapSet.new()
         }}

      result = @sut.new(:atoll, upper_left)

      assert result == expected
    end

    test "returns an error tuple if the island has any of its coords in an invalid position" do
      upper_left = coord!(9, 9)

      expected = {:error, :invalid_coordinate}

      result = @sut.new(:atoll, upper_left)

      assert result == expected
    end

    test "returns an error tuple if the island type is invalid" do
      upper_left = coord!(1, 1)

      expected = {:error, :invalid_island_shape}

      result = @sut.new(:circle, upper_left)

      assert result == expected
    end
  end

  defp coord!(row, col) do
    {:ok, coord} = Coordinate.new(row, col)
    coord
  end

  defp coords!(coord_list) do
    coord_list
    |> Enum.map(fn {r, c} -> coord!(r, c) end)
    |> MapSet.new()
  end
end
