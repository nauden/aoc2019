defmodule Day08 do
  def parse(str, w \\ 25, h \\ 6) do
    str
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(w * h)
    |> Enum.with_index()
    |> Enum.reduce(%{w: w, h: h, layers: %{}}, &parse_layer/2)
  end

  def parse_layer({layer, y}, %{w: w} = image) do
    layer
    |> Enum.chunk_every(w)
    |> Enum.with_index()
    |> Enum.reduce(%{}, &parse_row/2)
    |> (&put_in(image.layers[y], &1)).()
  end

  def parse_row({row, y}, layer) do
    row
    |> Enum.with_index()
    |> Enum.reduce(layer, fn {n, x}, acc -> put_in(acc[{x, y}], n) end)
  end

  def input() do
    File.read!("input/day08.txt")
    |> String.trim()
  end

  def fewest_zeroes(image) do
    image.layers
    |> Map.to_list()
    |> Enum.map(fn {l, m} ->
      {Map.values(m)
       |> Enum.count(&(&1 == 0)), l}
    end)
    |> Enum.min()
    |> elem(1)
  end

  def count_digits(layer, digit) do
    layer
    |> Map.values()
    |> Enum.reject(&(&1 != digit))
    |> length()
  end

  def show(%{w: w, h: h, layers: layers}) do
    num_layers = layers |> map_size

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        0..(num_layers - 1)
        |> Stream.map(&layers[&1][{x, y}])
        |> Stream.drop_while(&(&1 == 2))
        |> Enum.take(1)
        |> hd
        |> case do
          0 -> " "
          1 -> "#"
        end
      end
    end
    |> Enum.join("\n")
  end

  def part2() do
    input()
    |> parse()
    |> show()
    |> IO.puts()
  end

  def part1() do
    img =
      input()
      |> parse()

    fz = fewest_zeroes(img)

    count_digits(img.layers[fz], 1) *
      count_digits(img.layers[fz], 2)
  end
end
