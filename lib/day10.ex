defmodule Day10 do
  def input() do
    File.read!("input/day10.txt")
    |> String.split("\n", trim: true)
    |> parse()
  end

  def part1() do
    input()
    |> best_asteroid()
  end

  def part2() do
    input()
    |> zap_asteroids()
    |> Enum.at(199)
    |> (fn {x, y} -> x * 100 + y end).()
  end

  def zap_asteroids(asteroids) do
    {_, base} = best_asteroid(asteroids)

    asteroids
    |> Enum.reject(&(&1 == base))
    |> Stream.unfold(fn
      [] ->
        nil

      as ->
        to_zap = sweep_laser(as, base)
        {to_zap, as -- to_zap}
    end)
    |> Enum.to_list()
    |> List.flatten()
  end

  def sweep_laser(asteroids, base) do
    asteroids
    |> visible_from(base)
    |> Enum.map(&{distance(&1, base), &1})
    |> Enum.sort()
    |> Enum.reduce(%{}, fn {_, p}, m ->
      a = angle(p, base)
      # two points never have the same angle?
      Map.update(m, a, p, &([&1] ++ [p]))
    end)
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
  end

  def angle({px, py}, {ox, oy}) do
    a = :math.atan2(px - ox, oy - py) * 180 / :math.pi()
    if a < 0, do: a + 360, else: a
  end

  def visible_from(asteroids, {fromx, fromy} = p) do
    asteroids
    |> Enum.reject(&(&1 == p))
    |> Enum.reduce(%{}, fn {x, y}, visible ->
      dx = x - fromx
      dy = y - fromy

      g = gcd(dx, dy)
      np = {dx / g, dy / g}

      visible
      |> Map.update(np, {x, y}, &closest(&1, {x, y}, p))
    end)
    |> Map.values()
  end

  def best_asteroid(asteroids) do
    asteroids
    |> Enum.map(&{visible_from(asteroids, &1) |> length(), &1})
    |> Enum.sort()
    |> List.last()
  end

  def closest(a, b, origin) do
    da = distance(origin, a)
    db = distance(origin, b)

    if da < db, do: a, else: b
  end

  def distance({ax, ay}, {bx, by}) do
    abs(bx - ax) + abs(by - ay)
  end

  def gcd(x, 0), do: abs(x)
  def gcd(x, y) when x < 0, do: gcd(abs(x), y)
  def gcd(x, y) when y < 0, do: gcd(x, abs(y))
  def gcd(x, y), do: gcd(y, rem(x, y))

  def parse(rows) do
    h = length(rows)

    w =
      hd(rows)
      |> String.length()

    for {row, y} <- rows |> Enum.zip(0..h),
        {c, x} <-
          row
          |> String.graphemes()
          |> Enum.zip(0..w),
        c == "#" do
      {x, y}
    end
  end
end
