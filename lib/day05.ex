defmodule Day05 do
  @add 1
  @mul 2
  @input 3
  @output 4
  @jnz 5
  @jz 6
  @lt 7
  @eq 8
  @halt 99

  @position 0
  @immediate 1

  def decode(opcode) do
    {
      rem(opcode, 100),
      opcode
      |> div(100)
      |> Integer.digits()
      |> Enum.reverse()
      |> pad(3)
    }
  end

  def pad(l, n) when length(l) >= n, do: l
  def pad(l, n), do: pad(l ++ [0], n)

  def fetch(modes, ip, ins, n) do
    modes
    |> Enum.with_index(1)
    |> Enum.take(n)
    |> Enum.map(fn {mode, i} -> get(mode, ip, ins, i) end)
  end

  def get(mode, ip, ins, n) do
    case mode do
      @position -> elem(ins, elem(ins, ip + n))
      @immediate -> elem(ins, ip + n)
    end
  end

  def binary_op(modes, %{ip: ip, ins: ins} = cpu, op) do
    [a, b] = fetch(modes, ip, ins, 2)
    p = elem(ins, ip + 3)

    %{cpu | :ip => ip + 4, :ins => put_elem(ins, p, op.(a, b))}
    |> step()
  end

  def input(%{ip: ip, ins: ins, input: input} = cpu) do
    a = elem(ins, ip + 1)

    %{cpu | :ip => ip + 2, :ins => put_elem(ins, a, input)}
    |> step()
  end

  def output(modes, %{ip: ip, ins: ins} = cpu) do
    [a] = fetch(modes, ip, ins, 1)

    %{cpu | :ip => ip + 2}
    |> update_in([:output], fn v ->
      if v == nil, do: [a], else: v ++ [a]
    end)
    |> step()
  end

  def jmp_op(modes, cpu, cmp) do
    [a, b] = fetch(modes, cpu.ip, cpu.ins, 2)

    %{cpu | :ip => if(cmp.(a, 0), do: b, else: cpu.ip + 3)}
    |> step()
  end

  def set_if_op(modes, %{ip: ip, ins: ins} = cpu, cmp) do
    [a, b] = fetch(modes, ip, ins, 2)
    p = elem(ins, ip + 3)

    n =
      case cmp.(a, b) do
        true -> 1
        false -> 0
      end

    %{cpu | :ip => ip + 4, :ins => put_elem(ins, p, n)}
    |> step()
  end

  def run(ins, input) do
    step(%{ip: 0, ins: ins, input: input, output: []})
  end

  def step(%{ip: ip, ins: ins} = cpu) do
    {opcode, modes} = decode(elem(ins, ip))

    case opcode do
      @add -> binary_op(modes, cpu, &+/2)
      @mul -> binary_op(modes, cpu, &*/2)
      @input -> input(cpu)
      @output -> output(modes, cpu)
      @jnz -> jmp_op(modes, cpu, &!=/2)
      @jz -> jmp_op(modes, cpu, &==/2)
      @lt -> set_if_op(modes, cpu, &</2)
      @eq -> set_if_op(modes, cpu, &==/2)
      @halt -> cpu
    end
  end

  def parse(string) do
    string
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def input() do
    File.read!("input/day05.txt")
    |> String.trim()
    |> parse()
  end

  def part1() do
    input()
    |> run(1)
    |> get_in([:output])
    |> List.last()
  end

  def part2() do
    input()
    |> run(5)
    |> get_in([:output])
    |> hd()
  end
end
