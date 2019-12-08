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

  def feedback_loop(ins, phase) do
    phase
    |> Enum.map(&%{ip: 0, ins: ins, pause: true, output: 0, input: [&1]})
    |> List.update_at(0, &update_in(&1, [:input], fn v -> v ++ [0] end))
    |> Stream.unfold(&run_feedback_loop/1)
    |> Enum.to_list()
    |> List.last()
  end

  def run_feedback_loop([cpu | rest]) do
    case Intcode.run(cpu) do
      {:paused, paused_cpu} ->
        {paused_cpu.output,
         List.update_at(
           rest,
           0,
           &update_in(&1, [:input], fn v ->
             v ++ [paused_cpu.output]
           end)
         ) ++ [paused_cpu]}

      _ ->
        nil
    end
  end

  def run_amplifiers(ins, phase) do
    phase
    |> Enum.map(&%{ip: 0, ins: ins, output: 0, input: [&1]})
    |> Enum.reduce(0, fn cpu, acc ->
      cpu
      |> Map.update!(:input, &(&1 ++ [acc]))
      |> Intcode.run()
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
