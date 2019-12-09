defmodule Day09 do
  def input() do
    File.read!("input/day09.txt")
    |> Intcode.parse()
  end

  def part1() do
    input()
    |> Intcode.run(1)
    |> get_in([:output])
    |> hd
  end

  def part2() do
    input()
    |> Intcode.run(2)
    |> get_in([:output])
    |> hd
  end
end
