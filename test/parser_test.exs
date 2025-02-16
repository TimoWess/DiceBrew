defmodule DiceBrew.ParserTest do
  use ExUnit.Case, async: true
  alias DiceBrew.Parser
  alias DiceBrew.{FixedPart, RollPart}

  describe "parse/1" do
    test "parses a simple dice throw string into parts" do
      {:ok, parts} = Parser.parse("2d6+5")

      assert length(parts) == 1

      {label, part_list} = Enum.at(parts, 0)
      assert label == ""
      
      assert [%RollPart{amount: 2, sides: 6, sign: :plus}, %FixedPart{value: 5, sign: :plus}] == part_list
    end

    test "parses a labeled dice throw string" do
      {:ok, parts} = Parser.parse("1d8-3 [Fire]")

      assert length(parts) == 1

      {"[Fire]", part_list} = Enum.at(parts, 0)
      assert [%RollPart{amount: 1, sides: 8, sign: :plus}, %FixedPart{value: 3, sign: :minus}] == part_list
    end

    test "parses a dice throw string with multiple labels" do
      {:ok, parts} = Parser.parse("1d6+2 [Fire] 2d8-1 [Ice]")

      assert length(parts) == 2

      {"[Fire]", fire_parts} = Enum.at(parts, 0)
      assert [%RollPart{amount: 1, sides: 6, sign: :plus}, %FixedPart{value: 2, sign: :plus}] == fire_parts

      {"[Ice]", ice_parts} = Enum.at(parts, 1)
      assert [%RollPart{amount: 2, sides: 8, sign: :plus}, %FixedPart{value: 1, sign: :minus}] == ice_parts
    end
  end

  describe "parse!/1" do
    test "returns parsed parts for valid input" do
      parts = Parser.parse!("1d20+10")

      assert length(parts) == 1
      {label, part_list} = Enum.at(parts, 0)

      assert label == ""
      assert [%RollPart{amount: 1, sides: 20, sign: :plus}, %FixedPart{value: 10, sign: :plus}] == part_list
    end

    test "raises an error for invalid input" do
      assert_raise ArgumentError, fn -> Parser.parse!("invalid") end
    end
  end

  describe "parse/1 error handling" do
    test "returns an error tuple for invalid dice throw strings" do
      assert {:error, _message} = Parser.parse("1d20 + invalid")
    end

    test "handles empty input gracefully" do
      assert {:error, "Empty string provided"} = Parser.parse("")
    end
  end
end
