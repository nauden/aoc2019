defmodule Permutations do
  def of([] = l) when is_list(l) do
    [[]]
  end

  def of(list) when is_list(list) do
    for h <- list, t <- of(list -- [h]), do: [h | t]
  end

  def of(range), do: range |> Enum.to_list() |> of()
end
