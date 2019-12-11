defmodule Day11 do
  @up 0
  @right 1
  @down 2
  @left 3

  @black 0
  @white 1

  @mv %{@up => {0, -1}, @right => {1, 0}, @down => {0, 1}, @left => {-1, 0}}

  def input() do
    File.read!("input/day11.txt")
    |> Intcode.parse()
  end

  def part1() do
    input()
    |> robot()
    |> run()
    |> get_in([:panel])
    |> map_size()
  end

  def part2() do
    input()
    |> robot()
    |> put_in([:panel, {0, 0}], @white)
    |> run()
    |> show()
    |> IO.puts()
  end

  def show(%{panel: panel}) do
    pos = panel |> Map.keys()

    w = pos |> Enum.map(&elem(&1, 0)) |> Enum.max()
    h = pos |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..h do
      for x <- 0..w do
        case panel[{x, y}] do
          @white -> "#"
          _ -> " "
        end
      end
    end
    |> Enum.join("\n")
  end

  def robot(ins) do
    %{
      cpu: %{
        ins: ins,
        ip: 0,
        base: 0,
        pause: true,
        input: [],
        output: []
      },
      x: 0,
      y: 0,
      facing: @up,
      panel: %{}
    }
  end

  def move_forward(robot) do
    {dx, dy} = @mv[robot.facing]
    %{robot | x: robot.x + dx, y: robot.y + dy}
  end

  def turn(robot, 0) do
    %{robot | facing: if(robot.facing == @up, do: @left, else: robot.facing - 1)}
  end

  def turn(robot, 1), do: %{robot | facing: rem(robot.facing + 1, 4)}

  def paint(%{x: x, y: y} = robot, color) do
    put_in(robot.panel[{x, y}], color)
  end

  def run(%{x: x, y: y} = robot) do
    current_color = Map.get(robot.panel, {x, y}, @black)
    robot = put_in(robot.cpu.input, [current_color])

    case Intcode.step(robot.cpu) do
      {:paused, %{output: [color, turn]} = paused_cpu} ->
        put_in(robot.cpu, paused_cpu)
        |> paint(color)
        |> turn(turn)
        |> move_forward()
        |> put_in([:cpu, :output], [])
        |> run()

      {:paused, paused_cpu} ->
        put_in(robot.cpu, paused_cpu)
        |> run()

      _ ->
        robot
    end
  end
end
