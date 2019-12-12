defmodule Day05 do
  def input() do
    File.read!("input/day05.txt")
    |> String.trim()
    |> Intcode.parse()
  end

  def part1() do
    task =
      input()
      |> Intcode.run_async(self())

    send(task.pid, 1)
    Task.await(task)

    collect()
  end

  def collect() do
    receive do
      {:output, 0} -> collect()
      {:output, n} -> n
      _ -> collect()
    after
      100 -> IO.puts("timeout")
    end
  end

  def part2() do
    task =
      input()
      |> Intcode.run_async(self())

    send(task.pid, 5)
    Task.await(task)
    collect()
  end
end
