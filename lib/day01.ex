defmodule Day01 do
  def fuel(mass) when mass < 6, do: 0
  def fuel(mass), do: div(mass, 3) - 2

  def input() do
    File.read!("input/day01.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part1 do
    input()
    |> Enum.map(&fuel/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> Enum.map(fn m ->
      fuel(m)
      |> Stream.iterate(&fuel/1)
      |> Enum.take_while(&(&1 > 0))
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
