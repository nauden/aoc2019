defmodule Day06 do
  def parse(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ")", trim: true))
    |> Enum.reduce(%{}, fn [a, b], acc ->
      update_in(acc[a], &if(&1 == nil, do: [b], else: &1 ++ [b]))
    end)
  end

  def count_orbits(orbits) do
    orbits
    |> Map.values()
    |> List.flatten()
    |> Enum.map(&count_orbits(orbits, &1))
    |> Enum.sum()
  end

  def count_orbits(orbits, planet) do
    Map.get(orbits, planet, [])
    |> Enum.reduce(1, fn p, acc -> acc + count_orbits(orbits, p) end)
  end

  def input() do
    File.read!("input/day06.txt")
    |> parse()
  end

  def part1() do
    input()
    |> count_orbits()
  end

  def part2() do
    input()
    |> distance("YOU", "SAN")
  end

  def reverse(orbits) do
    orbits
    |> Enum.reduce(%{}, fn {parent, children}, acc ->
      children
      |> Enum.reduce(acc, fn child, acc ->
        update_in(acc[child], &if(&1 == nil, do: [parent], else: &1 ++ [parent]))
      end)
    end)
  end

  def distance(orbits, from, to) do
    rev = reverse(orbits)

    a =
      rev[from]
      |> Stream.iterate(&get_in(rev, &1))
      |> Enum.take_while(&(&1 != nil))
      |> List.flatten()
      |> Enum.with_index()
      |> Map.new()

    b =
      rev[to]
      |> Stream.iterate(&get_in(rev, &1))
      |> Enum.take_while(&(&1 != nil))
      |> List.flatten()
      |> Enum.with_index()
      |> Map.new()

    Map.keys(a)
    |> MapSet.new()
    |> MapSet.intersection(
      Map.keys(b)
      |> MapSet.new()
    )
    |> MapSet.to_list()
    |> Enum.map(&(a[&1] + b[&1]))
    |> Enum.min()
  end
end
