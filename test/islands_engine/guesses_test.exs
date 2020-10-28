defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  alias IslandsEngine.{Coordinate, Guesses}
  doctest Guesses

  @sut Guesses

  describe "new/2" do
    test "creates an empty guesses struct" do
      expected = %Guesses{hits: MapSet.new(), misses: MapSet.new()}

      result = @sut.new()

      assert result == expected
    end
  end

  describe "add/3" do
    test "adds a coordinate to the list of hits" do
      {:ok, coord} = Coordinate.new(1, 1)
      expected = %Guesses{hits: MapSet.new([coord]), misses: MapSet.new()}
      guesses = %Guesses{hits: MapSet.new(), misses: MapSet.new()}

      result = @sut.add(guesses, :hit, coord)

      assert result == expected
    end

    test "adds a coordinate to the list of misses" do
      {:ok, coord} = Coordinate.new(1, 1)
      expected = %Guesses{hits: MapSet.new(), misses: MapSet.new([coord])}
      guesses = %Guesses{hits: MapSet.new(), misses: MapSet.new()}

      result = @sut.add(guesses, :miss, coord)

      assert result == expected
    end
  end
end
