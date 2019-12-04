defmodule Day01 do
  import Enum, only: [map: 2, sum: 1]

  def fuel(mass), do: div(mass, 3) - 2

  def input() do
    File.read!("input/day01.txt")
    |> String.split("\n", trim: true)
    |> map(&String.to_integer/1)
  end

  def part1 do
    input() |> map(&fuel/1) |> sum()
  end

  def part2 do
    input()
    |> map(fn m ->
      fuel(m)
      |> Stream.iterate(&fuel/1)
      |> Enum.take_while(&(&1 > 0))
      |> sum()
    end)
    |> sum()
  end
end
