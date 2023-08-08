defmodule GameTest do
  use ExUnit.Case

  doctest Game

  test "new game" do
    assert Game.new() == [
             board: %Board{
               A1: :empty,
               A2: :empty,
               A3: :empty,
               B1: :empty,
               B2: :empty,
               B3: :empty,
               C1: :empty,
               C2: :empty,
               C3: :empty
             },
             turn: 0
           ]
  end

  test "put to empty board" do
    assert Game.new()
           |> Game.put(:A1) == {
             :ok,
             [
               board: %Board{
                 A1: :X,
                 A2: :empty,
                 A3: :empty,
                 B1: :empty,
                 B2: :empty,
                 B3: :empty,
                 C1: :empty,
                 C2: :empty,
                 C3: :empty
               },
               turn: 1
             ]
           }
  end

  test "put to occupied square" do
    {_, state} = Game.new() |> Game.put(:B3)

    assert Game.put(state, :B3) ==
             {:error,
              [
                board: %Board{
                  A1: :empty,
                  A2: :empty,
                  A3: :empty,
                  B1: :empty,
                  B2: :empty,
                  B3: :X,
                  C1: :empty,
                  C2: :empty,
                  C3: :empty
                },
                turn: 1
              ]}
  end

  test "Winner of new game is nil" do
    assert Game.new() |> Game.winner() == nil
  end

  test "Winner by row 1" do
    assert Game.winner(
             board: %Board{
               A1: :X,
               A2: :X,
               A3: :X,
               B1: :empty,
               B2: :empty,
               B3: :empty,
               C1: :empty,
               C2: :empty,
               C3: :empty
             },
             turn: 4
           ) == :X
  end

  test "Winner by row 2" do
    assert Game.winner(
             board: %Board{
               A1: :empty,
               A2: :empty,
               A3: :empty,
               B1: :O,
               B2: :O,
               B3: :O,
               C1: :empty,
               C2: :empty,
               C3: :empty
             },
             turn: 4
           ) == :O
  end

  test "Winner by row 3" do
    assert Game.winner(
             board: %Board{
               A1: :empty,
               A2: :empty,
               A3: :empty,
               B1: :empty,
               B2: :empty,
               B3: :empty,
               C1: :X,
               C2: :X,
               C3: :X
             },
             turn: 4
           ) == :X
  end

  test "Winner by col 1" do
    assert Game.winner(
             board: %Board{
               A1: :O,
               A2: :empty,
               A3: :empty,
               B1: :O,
               B2: :empty,
               B3: :empty,
               C1: :O,
               C2: :X,
               C3: :X
             },
             turn: 4
           ) == :O
  end

  test "Winner by col 2" do
    assert Game.winner(
             board: %Board{
               A1: :empty,
               A2: :X,
               A3: :O,
               B1: :empty,
               B2: :X,
               B3: :O,
               C1: :O,
               C2: :X,
               C3: :empty
             },
             turn: 4
           ) == :X
  end

  test "Winner by col 3" do
    assert Game.winner(
             board: %Board{
               A1: :empty,
               A2: :X,
               A3: :O,
               B1: :empty,
               B2: :empty,
               B3: :O,
               C1: :O,
               C2: :X,
               C3: :O
             },
             turn: 4
           ) == :O
  end

  test "Winner by diag 1" do
    assert Game.winner(
             board: %Board{
               A1: :X,
               A2: :empty,
               A3: :O,
               B1: :empty,
               B2: :X,
               B3: :empty,
               C1: :O,
               C2: :empty,
               C3: :X
             },
             turn: 4
           ) == :X
  end

  test "Winner by diag 2" do
    assert Game.winner(
             board: %Board{
               A1: :X,
               A2: :empty,
               A3: :O,
               B1: :empty,
               B2: :O,
               B3: :empty,
               C1: :O,
               C2: :empty,
               C3: :X
             },
             turn: 4
           ) == :O
  end
end
