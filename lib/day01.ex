defmodule Day01 do
  def fuel_req(mass), do: div(mass, 3) - 2

  def fuel_req2(mass) when mass <= 5, do: 0

  def fuel_req2(mass) do
    fuel = fuel_req(mass)
    fuel + fuel_req2(fuel)
  end

  def input() do
    File.read!("input/day01.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part1 do
    input()
    |> Enum.map(&fuel_req/1)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> Enum.map(&fuel_req2/1)
    |> Enum.sum()
  end
end
