defmodule TicTacToe do
  @moduledoc """
  Documentation for TicTacToe.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TicTacToe.hello()
      :world

  """
  def main(_args) do
    hello()
  end

  def hello() do
    IO.puts("hello world!")
    :world
  end

  def test(x, y) do
    x + y
  end
end

defmodule Board do
  @moduledoc """
  Struct representing a board in the game of TicTacToe
  """
  @type square :: :A1 | :A2 | :A3 | :B1 | :B2 | :B3 | :C1 | :C2 | :C3
  defstruct [:A1, :A2, :A3, :B1, :B2, :B3, :C1, :C2, :C3]
end

defmodule Game do
  @moduledoc """
  Model object for tic tac toe game
  """

  @type game_state :: [
          board: Board,
          turn: integer
        ]

  @default_board %Board{
    A1: :empty,
    A2: :empty,
    A3: :empty,
    B1: :empty,
    B2: :empty,
    B3: :empty,
    C1: :empty,
    C2: :empty,
    C3: :empty
  }

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

  def new() do
    [board: @default_board, turn: 0]
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
  @spec winner(state :: game_state) :: :X | :O | nil
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
end
