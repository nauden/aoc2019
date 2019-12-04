defmodule Day04 do
  def valid?(num) do
    ds = Integer.digits(num)
    acending?(ds) and has_repeat?(ds)
  end

  def valid2?(num) do
    ds = Integer.digits(num)
    acending?(ds) and has_exactly_two?(ds)
  end

  def acending?([_ | tail] = ds) do
    Enum.zip(ds, tail)
    |> Enum.all?(fn {a, b} -> a <= b end)
  end

  def has_repeat?(ds) do
    for d <- ds, reduce: %{} do
      m -> update_in(m[d], &if(&1 == nil, do: 1, else: &1 + 1))
    end
    |> Map.values()
    |> Enum.any?(&(&1 >= 2))
  end

  def has_exactly_two?(ds) do
    for d <- ds, reduce: %{} do
      m -> update_in(m[d], &if(&1 == nil, do: 1, else: &1 + 1))
    end
    |> Map.values()
    |> Enum.any?(&(&1 == 2))
  end

  def input(), do: 171_309..643_603

  def part1() do
    input()
    |> Enum.filter(&valid?/1)
    |> length
  end

  def part2() do
    input()
    |> Enum.filter(&valid2?/1)
    |> length
  end
end
