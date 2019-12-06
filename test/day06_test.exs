defmodule Day06Test do
  use ExUnit.Case, asyc: true
  doctest Day06

  @os Day06.parse("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\n")
  @os2 Day06.parse("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN\n")

  describe "parse orbits" do
    test "parse test orbit" do
      assert @os["COM"] == ["B"]
    end
  end

  test "counts orbits" do
    assert Day06.count_orbits(@os) == 42
  end

  test "can reverse map" do
    assert @os
           |> Day06.reverse()
           |> Day06.reverse() ==
             @os
  end

  describe "minimum orbital transfers" do
    test "finds minimum" do
      assert @os2
             |> Day06.distance("YOU", "SAN") == 4
    end
  end
end
