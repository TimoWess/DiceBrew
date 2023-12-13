defmodule DiceBrewTest do
  use ExUnit.Case
  doctest DiceBrew

  test "greets the world" do
    assert DiceBrew.hello() == :world
  end
end
