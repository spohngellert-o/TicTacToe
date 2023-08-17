defmodule BoardTest do
  use ExUnit.Case

  doctest Board

  test "Testing reading square on board" do
    assert Board.read_square("B3") == {:ok, :B3}
    assert Board.read_square("C2") == {:ok, :C2}
  end

  test "Testing reading square not on board" do
    assert Board.read_square("D1") == :error
  end
end

defmodule GameTest do
  use ExUnit.Case

  doctest Game

  test "new game" do
    assert Game.new() == [board: %Board{}, turn: 0]
  end

  test "put to empty board" do
    assert Game.new()
           |> Game.put(:A1) == {
             :ok,
             [
               board: %Board{
                 A1: :X
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
                  B3: :X
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
               A3: :X
             },
             turn: 4
           ) == :X
  end

  test "Winner by row 2" do
    assert Game.winner(
             board: %Board{
               B1: :O,
               B2: :O,
               B3: :O
             },
             turn: 4
           ) == :O
  end

  test "Winner by row 3" do
    assert Game.winner(
             board: %Board{
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
               B1: :O,
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
               A2: :X,
               A3: :O,
               B2: :X,
               B3: :O,
               C1: :O,
               C2: :X
             },
             turn: 4
           ) == :X
  end

  test "Winner by col 3" do
    assert Game.winner(
             board: %Board{
               A2: :X,
               A3: :O,
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
               A3: :O,
               B2: :X,
               C1: :O,
               C3: :X
             },
             turn: 4
           ) == :X
  end

  test "Winner by diag 2" do
    assert Game.winner(
             board: %Board{
               A1: :X,
               A3: :O,
               B2: :O,
               C1: :O,
               C3: :X
             },
             turn: 4
           ) == :O
  end

  test "Game result new game" do
    assert Game.game_result(Game.new()) == nil
  end

  test "Game result X won" do
    assert Game.game_result(board: %Board{A1: :X, B2: :X, C3: :X}, turn: 3) == :X
  end

  test "Game result full board" do
    assert Game.game_result(
             board: %Board{A1: :X, A2: :X, A3: :O, B1: :O, B2: :O, B3: :X, C1: :X, C2: :O, C3: :X},
             turn: 9
           ) == :tie
  end
end

defmodule TerminalViewTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  doctest TerminalView

  test "Get board str empty board" do
    empty_board_str = TerminalView.get_board_str(%Board{})
    assert not String.contains?(empty_board_str, "X")
    assert not String.contains?(empty_board_str, "O")
  end

  test "Get board str one placement" do
    board_str = TerminalView.get_board_str(%Board{B2: :X})
    assert String.match?(board_str, ~r/B\s*|\s*X\s*|/)
  end

  test "Get board str two placements" do
    board_str = TerminalView.get_board_str(%Board{B3: :O, C2: :X})
    assert String.match?(board_str, ~r/B\s*|\s*|\s*O/)
    assert String.match?(board_str, ~r/C\s*|\s*X\s*|/)
  end

  test "Test getting input for valid square" do
    {result, _output} =
      with_io([input: "A1"], fn ->
        mv = TerminalView.get_move(board: %Board{}, turn: 0)
        IO.write("A1")
        mv
      end)

    assert result == :A1
  end

  test "Test getting input for already played square" do
    {result, _output} =
      with_io([input: "A1"], fn ->
        mv = TerminalView.get_move(board: %Board{A1: :X}, turn: 1)
        IO.write("A1")
        mv
      end)

    assert result == :A1
  end

  test "Test getting input for invalid square" do
    {result, _output} =
      with_io([input: "D1"], fn ->
        mv = TerminalView.get_move(board: %Board{}, turn: 0)
        IO.write("A1")
        mv
      end)

    assert result == :error
  end

  test "Test on illegal move occupied square" do
    assert capture_io(fn -> TerminalView.on_illegal_move(:A2) end) =~
             "Attempted to play to square A2, which is already occupied. Please try another move."
  end

  test "Test on illegal move no square" do
    assert capture_io(fn -> TerminalView.on_illegal_move() end) =~
             "Input square was not recognized, please input a square in the format A-C|1-3 (ex: B2)."
  end

  test "Test on game end winner" do
    assert capture_io(fn -> TerminalView.on_game_over([board: %Board{}, turn: 0], :X) end) =~
             "X wins! Congrats!"
  end

  test "Test on game end tie" do
    assert capture_io(fn -> TerminalView.on_game_over([board: %Board{}, turn: 0], :tie) end) =~
             "It's a tie! Good game 🤝"
  end
end
