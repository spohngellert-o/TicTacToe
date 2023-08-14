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
  def square_to_str(:O), do: "O"
  def square_to_str(:X), do: "X"
  def square_to_str(:empty), do: " "

  @spec get_board_str(board :: Board) :: String.t()
  def get_board_str(board) do
    @squares
    |> Enum.reduce(@view_templ, fn sq, acc ->
      String.replace(acc, "~", square_to_str(Map.get(board, sq)), global: false)
    end)
  end
end
