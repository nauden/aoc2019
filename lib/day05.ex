defmodule Day05 do
  def input() do
    File.read!("input/day05.txt")
    |> String.trim()
    |> Intcode.parse()
  end

  def part1() do
    input()
    |> IO.inspect()
    |> Intcode.run(1)
  end

  def part2() do
    input()
    |> Intcode.run(5)
  end
end
