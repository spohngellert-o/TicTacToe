defmodule Board do
  @moduledoc """
  Struct representing a board in the game of TicTacToe
  """
  @type square_state :: :X | :O | nil
  @type square :: :A1 | :A2 | :A3 | :B1 | :B2 | :B3 | :C1 | :C2 | :C3
  defstruct [:A1, :A2, :A3, :B1, :B2, :B3, :C1, :C2, :C3]

  @type t :: %Board{
          A1: square_state(),
          A2: square_state(),
          A3: square_state(),
          B1: square_state(),
          B2: square_state(),
          B3: square_state(),
          C1: square_state(),
          C2: square_state(),
          C3: square_state()
        }

  @winning_trios [
    [:A1, :A2, :A3],
    [:B1, :B2, :B3],
    [:C1, :C2, :C3],
    [:A1, :B1, :C1],
    [:A2, :B2, :C2],
    [:A3, :B3, :C3],
    [:A1, :B2, :C3],
    [:A3, :B2, :C1]
  ]

  @doc """
  Reads in a square from string to atom format. If given string isn't a square, returns an error

  ## Examples
    iex> Board.read_square("A1")
    {:ok, :A1}
    iex> Board.read_square("D4")
    :error
  """
  @spec read_square(String.t()) :: {:ok, square()} | :error
  def read_square("A1"), do: {:ok, :A1}
  def read_square("A2"), do: {:ok, :A2}
  def read_square("A3"), do: {:ok, :A3}
  def read_square("B1"), do: {:ok, :B1}
  def read_square("B2"), do: {:ok, :B2}
  def read_square("B3"), do: {:ok, :B3}
  def read_square("C1"), do: {:ok, :C1}
  def read_square("C2"), do: {:ok, :C2}
  def read_square("C3"), do: {:ok, :C3}
  def read_square(_), do: :error

  @doc """
  Returns the winner of the game. If there is not yet a winner, returns nil.

  ## Examples

      iex> Board.winner(%Board{})
      nil

      iex> Board.winner(%Board{A1: :X, A3: :O, B2: :O, C1: :O, C3: :X})
      :O
  """
  @spec winner(board :: Board.t()) :: square_state()
  def winner(board) do
    @winning_trios
    |> Enum.reduce_while(nil, fn trio, _acc ->
      case trio_winner(board, trio) do
        nil -> {:cont, nil}
        winner -> {:halt, winner}
      end
    end)
  end

  @spec trio_winner(board :: Board.t(), trio :: [Board.square()]) :: square_state()
  defp trio_winner(board, trio) do
    placements = trio |> Enum.map(&Map.get(board, &1))
    Enum.reduce(placements, fn p, acc -> if p == acc and p != :empty, do: p, else: nil end)
  end

  @spec is_full?(Board.t()) :: boolean()
  def is_full?(board) do
    Enum.all?(Map.keys(board) |> tl, &(Map.get(board, &1) != nil))
  end
end

defmodule Game do
  @moduledoc """
  Model object for tic tac toe game
  """
  @enforce_keys [:board, :player_turn]
  defstruct [:board, :player_turn]

  @type player :: :X | :O
  @type game_result :: player() | :tie
  @type t :: %Game{board: Board.t(), player_turn: player()}

  @doc """
  Generates a new game
  """
  @spec new() :: Game.t()
  def new() do
    %Game{board: %Board{}, player_turn: :X}
  end

  @spec get_next_player(player()) :: player()
  defp get_next_player(:X), do: :O
  defp get_next_player(:O), do: :X

  @doc """
  Plays to the square, updating the board and whose turn it is.
  If the square is occupied, maintains the game state and returns an error atom.

  ## Examples

      iex> Game.put(Game.new(), :A1)
      %Game{board: %Board{A1: :X}, player_turn: :O}

      iex> Game.put(%Game{board: %Board{A1: :X, A2: :O, A3: :X, B1: :O, B2: :X, B3: :O, C1: :X, C2: :O, C3: :X}, player_turn: :O}, :A1)
      %Game{board: %Board{A1: :O, A2: :O, A3: :X, B1: :O, B2: :X, B3: :O, C1: :X, C2: :O, C3: :X}, player_turn: :X}
  }]
  """
  @spec put(game :: Game.t(), square :: Board.square()) :: Game.t()
  def put(%Game{board: board, player_turn: p}, square) do
    %Game{board: Map.put(board, square, p), player_turn: get_next_player(p)}
  end

  @doc """
  Determines the game result based on the game state.
  A game is over when it satisfies one of two conditions:
  1. A player has gotten 3 in a row (there's a winner)
  2. All tiles are filled (9 turns have been completed)

  Returns the winner or :tie based on this.

  ## Examples

    iex> Game.game_result(Game.new())
    nil
    iex> Game.game_result(%Game{board: %Board{A1: :X, A2: :X, A3: :X}, player_turn: :O})
    :X
    iex> Game.game_result(%Game{board: %Board{A1: :X, A2: :X, A3: :O, B1: :O, B2: :O, B3: :X, C1: :X, C2: :O, C3: :X}, player_turn: :O})
    :tie
  """
  @spec game_result(game :: Game.t() | nil) :: game_result() | nil
  def game_result(game) do
    winner = Board.winner(game.board)

    cond do
      winner != nil -> winner
      Board.is_full?(game.board) -> :tie
      true -> nil
    end
  end
end

defmodule TerminalView do
  @moduledoc """
  Module for viewing a tic tac toe game via the terminal. Includes
  functions for printing the board to the terminal and taking in moves.
  """

  @view_templ """
      1     2     3
         |     |
  A   ~  |  ~  |  ~
    _____|_____|_____
         |     |
  B   ~  |  ~  |  ~
    _____|_____|_____
         |     |
  C   ~  |  ~  |  ~
         |     |
  >>
  """

  @squares [:A1, :A2, :A3, :B1, :B2, :B3, :C1, :C2, :C3]

  @spec square_to_str(Board.square_state()) :: String.t()
  defp square_to_str(:O), do: "O"
  defp square_to_str(:X), do: "X"
  defp square_to_str(nil), do: " "

  @doc """
  Gets the board string to be printed to the terminal.
  """
  @spec get_board_str(board :: Board.t()) :: String.t()
  def get_board_str(board) do
    @squares
    |> Enum.reduce(@view_templ, fn sq, acc ->
      String.replace(acc, "~", square_to_str(Map.get(board, sq)), global: false)
    end)
    |> String.trim_trailing()
  end

  @doc """
  Uses terminal input to get the square a player wants to play. If an invalid
  input is given :error is returned.
  """
  @spec get_move(game :: Game.t()) :: Board.square() | :error
  def get_move(game) do
    square_str =
      IO.gets(
        "It's #{game.player_turn}'s turn, play your move!\n" <>
          get_board_str(game.board)
      )

    case Board.read_square(String.trim(square_str)) do
      {:ok, square} -> square
      :error -> :error
    end
  end

  @doc """
  Handles illegal moves, in this case by printing that the move was illegal to the console
  """
  @spec on_illegal_move(move :: Board.square() | :error) :: :ok
  def on_illegal_move(move \\ :error)

  def on_illegal_move(move) when move != :error do
    IO.puts(
      "Attempted to play to square #{Atom.to_string(move)}, which is already occupied. Please try another move."
    )
  end

  def on_illegal_move(:error) do
    IO.puts(
      "Input square was not recognized, please input a square in the format A-C|1-3 (ex: B2)."
    )
  end

  @doc """
  Handles the game being over, in this case by printing the winner
  """
  @spec on_game_over(Game.t(), result :: Game.game_result()) :: :ok
  def on_game_over(%Game{board: board, player_turn: _p}, result) do
    IO.puts(get_board_str(board))

    case result do
      :tie -> IO.puts("It's a tie! Good game 🤝")
      res when res in [:X, :O] -> IO.puts("#{Atom.to_string(res)} wins! Congrats!")
    end
  end
end

defmodule Controller do
  @moduledoc """
  Controller for TicTacToe game. Currently hard coded to use TerminalView,
  but theoretically could use any view.
  """

  @doc """
  Plays out a game of TicTacToe from the given game state
  """
  @spec play(game :: Game.t()) :: :ok
  def play(game \\ Game.new()) do
    case Game.game_result(game) do
      nil -> play(handle_turn(game))
      res -> TerminalView.on_game_over(game, res)
    end
  end

  @spec handle_turn(game :: Game.t()) :: Game.t()
  defp handle_turn(game) do
    case TerminalView.get_move(game) do
      :error ->
        TerminalView.on_illegal_move(:error)
        game

      sq ->
        handle_move(game, sq)
    end
  end

  @spec handle_move(game :: Game.t(), sq :: Board.square()) :: Game.t()
  defp handle_move(game = %Game{board: board, player_turn: _p}, sq) do
    case Map.get(board, sq) do
      nil ->
        Game.put(game, sq)

      _ ->
        TerminalView.on_illegal_move(sq)
        game
    end
  end
end

defmodule TicTacToe do
  @moduledoc """
  Main module for running a tic tac toe game.
  """
  @spec main(any) :: :ok
  def main(_args) do
    Controller.play(Game.new())
  end
end
