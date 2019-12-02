defmodule Day02 do
  def run([ip: ip, ins: ins] = cpu) when elem(ins, ip) == 1 do
    run(ip: ip + 4, ins: put_elem(ins, p(cpu), a(cpu) + b(cpu)))
  end

  def run([ip: ip, ins: ins] = cpu) when elem(ins, ip) == 2 do
    run(ip: ip + 4, ins: put_elem(ins, p(cpu), a(cpu) * b(cpu)))
  end

  def run(ip: ip, ins: ins) when elem(ins, ip) == 99 do
    elem(ins, 0)
  end

  def run(ins: ins, verb: verb, noun: noun) do
    run(
      ip: 0,
      ins:
        ins
        |> put_elem(1, verb)
        |> put_elem(2, noun)
    )
  end

  def a(ip: ip, ins: ins), do: elem(ins, elem(ins, ip + 1))
  def b(ip: ip, ins: ins), do: elem(ins, elem(ins, ip + 2))
  def p(ip: ip, ins: ins), do: elem(ins, ip + 3)

  def input() do
    File.read!("input/day02.txt")
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def part1() do
    run(ins: input(), verb: 12, noun: 2)
  end

  def part2() do
    ins = input()

    for verb <- 0..99, noun <- 0..99 do
      {verb, noun}
    end
    |> Enum.find(fn {verb, noun} ->
      run(ins: ins, verb: verb, noun: noun) == 19_690_720
    end)
    |> (fn {v, n} -> 100 * v + n end).()
  end
end
