defmodule Day09 do
  def input() do
    File.read!("input/day09.txt")
    |> Intcode.parse()
  end

  def part1() do
    t =
      input()
      |> Intcode.run_async(self())

    send(t.pid, 1)
    Task.await(t)
    collect()
  end

  def collect() do
    receive do
      {:output, n} when n > 3000 ->
        n

      {:output, n} ->
        IO.puts(n)
        collect()
    after
      10 -> raise("timeout")
    end
  end

  def part2() do
    t =
      input()
      |> Intcode.run_async(self())

    send(t.pid, 2)
    Task.await(t)
    collect()
  end
end
