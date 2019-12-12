defmodule Day12 do
  def input() do
    File.read!("input/day12.txt")
    |> String.split("\n", trim: true)
    |> parse()
  end

  def part1() do
    input()
    |> Stream.iterate(&step/1)
    |> Stream.drop(1000)
    |> Enum.take(1)
    |> hd
    |> Enum.map(&energy/1)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> find_cycle()
  end

  def find_cycle(moons) do
    Enum.map(0..2, fn n ->
      Stream.iterate(moons, &step/1)
      |> Enum.reduce_while(MapSet.new(), fn ms, seen ->
        cs = extract(ms, n)

        if MapSet.member?(seen, cs) do
          {:halt, seen}
        else
          {:cont, MapSet.put(seen, cs)}
        end
      end)
      |> MapSet.size()
    end)
    |> lcm()
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))
  def lcm([a, b, c]), do: lcm(a, lcm(b, c))

  def extract(moons, c) do
    moons
    |> Enum.map(fn [p: p, v: v] -> {elem(p, c), elem(v, c)} end)
  end

  def step(moons) do
    moons
    |> gravity
    |> Enum.map(&move/1)
  end

  def parse(str) do
    r = ~r{([-\d]+)}

    str
    |> Enum.map(&Regex.scan(r, &1, capture: :all_but_first))
    |> Enum.map(fn row ->
      Enum.map(row, fn [v] -> String.to_integer(v) end)
    end)
    |> Enum.map(&[p: List.to_tuple(&1), v: {0, 0, 0}])
  end

  def gravity(moons) do
    moons
    |> Enum.reduce([], fn m, acc ->
      acc ++ [[m, for(o <- moons, o != m, do: o)]]
    end)
    |> Enum.map(fn [m, ms] -> Enum.reduce(ms, m, &diff/2) end)
  end

  def diff([p: p2, v: _], p: p, v: {vx, vy, vz}) do
    {x, y, z} = p
    {x2, y2, z2} = p2

    [
      p: p,
      v: {
        cond do
          x < x2 -> vx + 1
          x > x2 -> vx - 1
          x == x2 -> vx
        end,
        cond do
          y < y2 -> vy + 1
          y > y2 -> vy - 1
          y == y2 -> vy
        end,
        cond do
          z < z2 -> vz + 1
          z > z2 -> vz - 1
          z == z2 -> vz
        end
      }
    ]
  end

  def energy(p: {x, y, z}, v: {vx, vy, vz}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  def move(p: {x, y, z}, v: {vx, vy, vz} = v) do
    [p: {x + vx, y + vy, z + vz}, v: v]
  end
end
