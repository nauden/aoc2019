defmodule Day07 do
  def part1() do
    input()
    |> highest_phase()
  end

  def part2() do
    input()
    |> highest_feedback()
  end

  def highest_feedback(ins) do
    Permutations.of(5..9)
    |> Enum.map(&feedback_loop(ins, &1))
    |> Enum.max()
  end

  def feedback_loop(ins, phases) do
    tasks =
      phases
      |> Enum.map(fn phase ->
        t = Intcode.run_async(ins, self())
        send(t.pid, phase)
        t
      end)

    tasks |> hd |> (&send(&1.pid, 0)).()

    tasks
    |> Stream.unfold(&run_feedback_loop/1)
    |> Enum.to_list()
    |> List.last()
  end

  def run_feedback_loop([task | rest]) do
    if Process.alive?(task.pid) do
      output =
        receive do
          {:output, n} -> n
        after
          10 -> raise("timeout!")
        end

      rest |> hd |> (&send(&1.pid, output)).()

      {output, rest ++ [task]}
    else
      nil
    end
  end

  def run_amplifiers(ins, phases) do
    phases
    |> Enum.map(fn phase ->
      t = Intcode.run_async(ins, self())
      send(t.pid, phase)
      t
    end)
    |> Enum.reduce(0, fn task, acc ->
      send(task.pid, acc)
      Task.await(task)

      receive do
        {:output, n} -> n
      after
        10 -> raise("timeout!")
      end
    end)
  end

  def highest_phase(ins) do
    Permutations.of(0..4)
    |> Enum.map(&run_amplifiers(ins, &1))
    |> Enum.max()
  end

  def input() do
    File.read!("input/day07.txt")
    |> String.trim()
    |> Intcode.parse()
  end
end
