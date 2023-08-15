defmodule Board do
  @moduledoc """
  Struct representing a board in the game of TicTacToe
  """
  @type square_state :: :X | :O | :empty
  @type player :: :X | :O
  @type square :: :A1 | :A2 | :A3 | :B1 | :B2 | :B3 | :C1 | :C2 | :C3
  defstruct A1: :empty,
            A2: :empty,
            A3: :empty,
            B1: :empty,
            B2: :empty,
            B3: :empty,
            C1: :empty,
            C2: :empty,
            C3: :empty

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
end

defmodule Game do
  @moduledoc """
  Model object for tic tac toe game
  """

  @type game_result :: Board.player() | :tie
  @type game_state :: [
          board: Board,
          turn: integer
        ]

  @turn_order List.duplicate([:X, :O], 9) |> List.flatten()
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
  Generates a new game
  """
  @spec new() :: game_state()
  def new() do
    [board: %Board{}, turn: 0]
  end

  @doc """
  Plays to the square, updating the board and whose turn it is.
  If the square is occupied, maintains the game state and returns an error atom.

  ## Examples

      iex> Game.put([board: %Board{A1: :empty, A2: :empty, A3: :empty, B1: :empty, B2: :empty, B3: :empty, C1: :empty, C2: :empty, C3: :empty}, turn: 0], :A1)
      {:ok, [board: %Board{A1: :X, A2: :empty, A3: :empty, B1: :empty, B2: :empty, B3: :empty, C1: :empty, C2: :empty, C3: :empty}, turn: 1]}

      iex> Game.put([board: %Board{A1: :X, A2: :O, A3: :X, B1: :O, B2: :X, B3: :O, C1: :X, C2: :O, C3: :X}, turn: 9], :A1)
      {:error, [board: %Board{A1: :X, A2: :O, A3: :X, B1: :O, B2: :X, B3: :O, C1: :X, C2: :O, C3: :X}, turn: 9]}
  }]
  """
  @spec put(state :: game_state, square :: Board.square()) :: {:ok | :error, game_state}
  def put(state = [board: board, turn: turn], square) do
    if Map.get(board, square) == :empty do
      {:ok, [board: Map.put(board, square, Enum.at(@turn_order, turn)), turn: turn + 1]}
    else
      {:error, state}
    end
  end

  @spec get_player_turn(game_state :: game_state()) :: Board.player()
  def get_player_turn(board: _board, turn: turn), do: Enum.at(@turn_order, turn)

  @doc """
  Returns the winner of the game. If there is not yet a winner, returns nil.

  ## Examples

      iex> Game.winner(Game.new())
      nil

      iex> Game.winner(board: %Board{A1: :X, A2: :empty, A3: :O, B1: :empty, B2: :O, B3: :empty, C1: :O, C2: :empty, C3: :X}, turn: 4)
      :O
  """
  @spec winner(state :: game_state) :: Board.player() | nil
  def winner(board: board, turn: _turn) do
    @winning_trios
    |> Enum.reduce_while(nil, fn trio, _acc ->
      case trio_winner(board, trio) do
        nil -> {:cont, nil}
        winner -> {:halt, winner}
      end
    end)
  end

  @spec trio_winner(board :: Board, trio :: [Board.square()]) :: :X | :O | nil
  defp trio_winner(board, trio) do
    placements = trio |> Enum.map(&Map.get(board, &1))
    Enum.reduce(placements, fn p, acc -> if p == acc and p != :empty, do: p, else: nil end)
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
    iex> Game.game_result(board: %Board{A1: :X, A2: :X, A3: :X}, turn: 3)
    :X
    iex> Game.game_result(board: %Board{}, turn: 9)
    :tie
  """
  @spec game_result(state :: game_state) :: game_result() | nil
  def game_result(state = [board: _board, turn: turn]) do
    winner = winner(state)

    cond do
      winner != nil -> winner
      turn >= 9 -> :tie
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
  """

  @squares [:A1, :A2, :A3, :B1, :B2, :B3, :C1, :C2, :C3]

  @spec square_to_str(Board.square_state()) :: String.t()
  defp square_to_str(:O), do: "O"
  defp square_to_str(:X), do: "X"
  defp square_to_str(:empty), do: " "

  @doc """
  Gets the board string to be printed to the terminal.
  """
  @spec get_board_str(board :: Board) :: String.t()
  def get_board_str(board) do
    @squares
    |> Enum.reduce(@view_templ, fn sq, acc ->
      String.replace(acc, "~", square_to_str(Map.get(board, sq)), global: false)
    end)
  end

  @doc """
  Uses terminal input to get the square a player wants to play. If an invalid
  input is given :error is returned.
  """
  @spec get_move(game_state :: Game.game_state()) :: Board.square() | :error
  def get_move(game_state = [board: board, turn: _turn]) do
    square_str =
      IO.gets(
        "It's #{Game.get_player_turn(game_state)}'s turn, play your move!\n" <>
          get_board_str(board)
      )

    case Board.read_square(String.trim(square_str)) do
      {:ok, square} -> square
      :error -> :error
    end
  end
end
