defmodule Day02 do
  @doc """
  iex> Day02.run(ip: 0, ins: {1,9,10,3,2,3,11,0,99,30,40,50})
  3500

  iex> Day02.run(ip: 0, ins: {1,1,1,4,99,5,6,0,99})
  30
  """
  def run([ip: ip, ins: ins] = cpu) when elem(ins, ip) == 1 do
    run(ip: ip + 4, ins: put_elem(ins, p(cpu), a(cpu) + b(cpu)))
  end

  def run([ip: ip, ins: ins] = cpu) when elem(ins, ip) == 2 do
    run(ip: ip + 4, ins: put_elem(ins, p(cpu), a(cpu) * b(cpu)))
  end

  def run(ip: ip, ins: ins) when elem(ins, ip) == 99 do
    elem(ins, 0)
  end

  def run(ins: ins, noun: noun, verb: verb) do
    run(
      ip: 0,
      ins:
        ins
        |> put_elem(1, noun)
        |> put_elem(2, verb)
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
    run(ins: input(), noun: 12, verb: 2)
  end

  def part2() do
    ins = input()

    for(noun <- 0..99, verb <- 0..99, do: {noun, verb})
    |> Enum.find(fn {noun, verb} ->
      run(ins: ins, noun: noun, verb: verb) == 19_690_720
    end)
    |> (fn {n, v} -> 100 * n + v end).()
  end
end
