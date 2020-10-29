defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Coordinate
  doctest Coordinate

  @sut Coordinate

  describe "new/2" do
    test "creates a new coordinate struct in an ok tuple when values are correct" do
      expected = {:ok, %Coordinate{row: 1, col: 8}}

      result = @sut.new(1, 8)

      assert result == expected
    end

    test "returns an error tuple when the row is invalid" do
      expected = {:error, :invalid_coordinate}

      result = @sut.new(11, 8)

      assert result == expected
    end

    test "returns an error tuple when the col is invalid" do
      expected = {:error, :invalid_coordinate}

      result = @sut.new(5, -1)

      assert result == expected
    end

    test "returns an error tuple when bolt col and row are invalid" do
      expected = {:error, :invalid_coordinate}

      result = @sut.new(-1, -1)

      assert result == expected
    end
  end
end
