defmodule Intcode do
  @add 1
  @mul 2
  @input 3
  @output 4
  @jnz 5
  @jz 6
  @lt 7
  @eq 8
  @adjust 9
  @halt 99

  @position 0
  @immediate 1
  @relative 2

  def run_async(ins, caller) do
    Task.async(fn ->
      %{ip: 0, ins: ins, base: 0, caller: caller}
      |> step()
    end)
  end

  def run_sync(ins) do
    %{ip: 0, ins: ins, base: 0}
    |> step()
  end

  defp decode(opcode) do
    {
      rem(opcode, 100),
      opcode
      |> div(100)
      |> Integer.digits()
      |> Enum.reverse()
      |> pad(3)
    }
  end

  defp pad(l, n) when length(l) >= n, do: l
  defp pad(l, n), do: pad(l ++ [0], n)

  defp fetch(modes, cpu, n) do
    modes
    |> Enum.with_index(1)
    |> Enum.take(n)
    |> Enum.map(fn {mode, i} -> get(mode, cpu, i) end)
  end

  defp get(mode, %{ip: ip, ins: ins, base: base}, n) do
    case mode do
      @position -> :array.get(:array.get(ip + n, ins), ins)
      @immediate -> :array.get(ip + n, ins)
      @relative -> :array.get(base + :array.get(ip + n, ins), ins)
    end
  end

  defp idx(mode, %{ip: ip, ins: ins, base: base}, n) do
    case mode do
      @position -> :array.get(ip + n, ins)
      @immediate -> raise "cannot get immediate index"
      @relative -> base + :array.get(ip + n, ins)
    end
  end

  defp binary_op(modes, %{ip: ip, ins: ins} = cpu, op) do
    [a, b] = fetch(modes, cpu, 2)
    p = idx(List.last(modes), cpu, 3)

    %{cpu | :ip => ip + 4, :ins => :array.set(p, op.(a, b), ins)}
    |> step()
  end

  defp input(modes, %{ip: ip, ins: ins} = cpu) do
    receive do
      n when is_integer(n) ->
        p = idx(hd(modes), cpu, 1)

        %{cpu | :ip => ip + 2, :ins => :array.set(p, n, ins)}

      _ ->
        raise("Bad input received")
    end
    |> step()
  end

  defp output(modes, %{ip: ip, caller: caller} = cpu) do
    [a] = fetch(modes, cpu, 1)

    send(caller, {:output, a})

    %{cpu | :ip => ip + 2}
    |> step()
  end

  defp output(_), do: raise("no pid to send messages to")

  defp jmp_op(modes, cpu, cmp) do
    [a, b] = fetch(modes, cpu, 2)

    %{cpu | :ip => if(cmp.(a, 0), do: b, else: cpu.ip + 3)}
    |> step()
  end

  defp set_if_op(modes, %{ip: ip, ins: ins} = cpu, cmp) do
    [a, b] = fetch(modes, cpu, 2)
    p = idx(List.last(modes), cpu, 3)

    n = if cmp.(a, b), do: 1, else: 0

    %{cpu | :ip => ip + 4, :ins => :array.set(p, n, ins)}
    |> step()
  end

  defp adjust(modes, %{ip: ip, base: base} = cpu) do
    [a] = fetch(modes, cpu, 1)

    %{cpu | :ip => ip + 2, :base => base + a}
    |> step()
  end

  defp step(%{ip: ip, ins: ins} = cpu) do
    {opcode, modes} = decode(:array.get(ip, ins))

    case opcode do
      @add -> binary_op(modes, cpu, &+/2)
      @mul -> binary_op(modes, cpu, &*/2)
      @input -> input(modes, cpu)
      @output -> output(modes, cpu)
      @jnz -> jmp_op(modes, cpu, &!=/2)
      @jz -> jmp_op(modes, cpu, &==/2)
      @lt -> set_if_op(modes, cpu, &</2)
      @eq -> set_if_op(modes, cpu, &==/2)
      @adjust -> adjust(modes, cpu)
      @halt -> cpu
    end
  end

  def parse(string) do
    string
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list(0)
  end
end
