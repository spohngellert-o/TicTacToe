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
