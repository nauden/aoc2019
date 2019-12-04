defmodule Day03 do
  @doc """
  iex> Day03.closest_intersection(["R8,U5,L5,D3", "U7,R6,D4,L4"])
  6

  iex> Day03.closest_intersection(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
  159

  iex> Day03.closest_intersection(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
  135

  iex> Day03.shortest_path(["R8,U5,L5,D3", "U7,R6,D4,L4"])
  30

  iex> Day03.shortest_path(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
  610

  iex> Day03.shortest_path(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
  410
  """

  @m %{?R => {1, 0}, ?L => {-1, 0}, ?U => {0, -1}, ?D => {0, 1}}

  def trace(path) when is_binary(path) do
    trace(path: parse(path), pos: {0, 0}, vs: %{}, steps: 0)
  end

  def trace(path: [<<d, ss::binary>> | rest], pos: {x, y}, vs: vs, steps: steps) do
    dist = String.to_integer(ss)
    {dx, dy} = @m[d]

    ps =
      for(
        px <- x..(x + dx * dist),
        py <- y..(y + dy * dist),
        do: {px, py}
      )
      |> Enum.zip(steps..(steps + dist))

    {np, ns} = List.last(ps)

    nvs =
      Enum.reduce(ps, vs, fn {pos, s}, acc ->
        update_in(acc[pos], &if(&1 == nil, do: s, else: &1))
      end)

    trace(path: rest, pos: np, vs: nvs, steps: ns)
  end

  def trace(path: [], pos: _, vs: vs, steps: _), do: vs

  def distance({x, y}), do: abs(x) + abs(y)

  def parse(path) do
    path
    |> String.split(",", trim: true)
  end

  def closest_intersection([path1, path2]) do
    t1 = trace(path1)
    t2 = trace(path2)

    s1 = MapSet.new(t1, fn {p, _} -> p end)

    MapSet.new(t2, fn {p, _} -> p end)
    |> MapSet.intersection(s1)
    |> MapSet.to_list()
    |> Enum.map(&distance/1)
    |> Enum.reject(&(&1 == 0))
    |> Enum.min()
  end

  def input() do
    File.read!("input/day03.txt")
    |> String.split()
  end

  def shortest_path([path1, path2]) do
    t1 = trace(path1)
    t2 = trace(path2)

    s1 = MapSet.new(t1, fn {p, _} -> p end)

    MapSet.new(t2, fn {p, _} -> p end)
    |> MapSet.intersection(s1)
    |> MapSet.to_list()
    |> Enum.reject(&(&1 == {0, 0}))
    |> Enum.map(&(t1[&1] + t2[&1]))
    |> Enum.min()
  end

  def part1() do
    input()
    |> closest_intersection()
  end

  def part2() do
    input()
    |> shortest_path()
  end
end
