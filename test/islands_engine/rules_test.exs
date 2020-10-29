defmodule IslandsEngine.RulesTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Rules}
  doctest Rules

  @sut Rules

  @all_actions [
    :add_player,
    {:position_island, :player1},
    {:position_island, :player2},
    {:set_islands, :player1},
    {:set_islands, :player2},
    {:guess_coordinate, :player1},
    {:guess_coordinate, :player2},
    {:win_check, :win},
    {:win_check, :no_win}
  ]

  describe "new/0" do
    test "creates a new and empty rules struct" do
      expected = %Rules{}

      result = @sut.new()

      assert result == expected
    end
  end

  describe "check/2" do
    test "initialized: add_player changes the state from initialized to players_set" do
      rules = %Rules{}

      expected = %Rules{state: :players_set}

      {:ok, result} = @sut.check(rules, :add_player)

      assert result == expected
    end

    test "initialized: errors for any other action" do
      rules = %Rules{}
      [_add_player | actions] = @all_actions

      for action <- actions do
        assert @sut.check(rules, action) == :error
      end
    end

    test "players_set: set_islands changes the state to player1_turn when both players set their islands" do
      rules = %Rules{state: :players_set}

      {:ok, result1} = @sut.check(rules, {:set_islands, :player1})

      assert result1 == %Rules{
               state: :players_set,
               player1: :islands_set,
               player2: :island_not_set
             }

      {:ok, result2} = @sut.check(result1, {:set_islands, :player2})
      assert result2 == %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}
    end

    test "players_set: position_islands does not change the state" do
      rules = %Rules{state: :players_set}

      {:ok, result} = @sut.check(rules, {:position_islands, :player1})
      assert result == rules

      {:ok, result} = @sut.check(rules, {:position_islands, :player2})
      assert result == rules
    end

    test "players_set: position_islands errors if we try to position of a player that has islands_set" do
      rules = %Rules{state: :players_set, player1: :island_set}

      result = @sut.check(rules, {:position_islands, :player1})
      assert result == :error
    end

    test "players_set: errors for all other actions" do
      player_set_actions = [
        {:set_islands, :player1},
        {:set_islands, :player2},
        {:position_islands, :player1},
        {:position_islands, :player2}
      ]

      rules = %Rules{state: :players_set}
      actions = Enum.filter(@all_actions, &(&1 not in player_set_actions))

      for action <- actions do
        assert @sut.check(rules, action) == :error
      end
    end

    test "player1_turn: guess_coordinate changes the state to player2_turn" do
      rules = %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}
      expected = %Rules{rules | state: :player2_turn}

      {:ok, result} = @sut.check(rules, {:guess_coordinate, :player1})

      assert result == expected
    end

    test "player1_turn: {win_check, win} changes the state to game_over" do
      rules = %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}
      expected = %Rules{rules | state: :game_over}

      {:ok, result} = @sut.check(rules, {:win_check, :win})

      assert result == expected
    end

    test "player1_turn: {win_check, no_win} does not change state" do
      rules = %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}
      expected = rules

      {:ok, result} = @sut.check(rules, {:win_check, :no_win})

      assert result == expected
    end

    test "player1_turn: errors for all other actions" do
      possible_actions = [
        {:guess_coordinate, :player1},
        {:win_check, :win},
        {:win_check, :no_win}
      ]

      rules = %Rules{state: :player1_turn}
      actions = Enum.filter(@all_actions, &(&1 not in possible_actions))

      for action <- actions do
        assert @sut.check(rules, action) == :error
      end
    end

    test "player2_turn: guess_coordinate changes the state to player1_turn" do
      rules = %Rules{state: :player2_turn, player1: :islands_set, player2: :islands_set}
      expected = %Rules{rules | state: :player1_turn}

      {:ok, result} = @sut.check(rules, {:guess_coordinate, :player2})

      assert result == expected
    end

    test "player2_turn: win_check changes the state to game_over" do
      rules = %Rules{state: :player2_turn, player1: :islands_set, player2: :islands_set}
      expected = %Rules{rules | state: :game_over}

      {:ok, result} = @sut.check(rules, {:win_check, :win})

      assert result == expected
    end

    test "player2_turn: {win_check, no_win} does not change state" do
      rules = %Rules{state: :player2_turn, player1: :islands_set, player2: :islands_set}
      expected = rules

      {:ok, result} = @sut.check(rules, {:win_check, :no_win})

      assert result == expected
    end

    test "player2_turn: errors for all other actions" do
      possible_actions = [
        {:guess_coordinate, :player2},
        {:win_check, :win},
        {:win_check, :no_win}
      ]

      rules = %Rules{state: :player2_turn}
      actions = Enum.filter(@all_actions, &(&1 not in possible_actions))

      for action <- actions do
        assert @sut.check(rules, action) == :error
      end
    end
  end
end
