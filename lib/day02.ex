defmodule Day02 do
  def input() do
    File.read!("input/day02.txt")
    |> Intcode.parse()
  end

  def set_values(ins, noun, verb) do
    :array.set(1, noun, ins)
    |> (&:array.set(2, verb, &1)).()
  end

  def part1() do
    input()
    |> set_values(12, 2)
    |> Intcode.run(1)
    |> (&:array.get(0, &1.ins)).()
  end

  def part2() do
    ins = input()

    for(noun <- 0..99, verb <- 0..99, do: {noun, verb})
    |> Enum.find(fn {noun, verb} ->
      ins
      |> set_values(noun, verb)
      |> Intcode.run(1)
      |> (&:array.get(0, &1.ins)).() == 19_690_720
    end)
    |> (fn {n, v} -> 100 * n + v end).()
  end
end
