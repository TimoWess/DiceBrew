defmodule DiceBrew.RollOptionsTest do
  use ExUnit.Case, async: true
  alias DiceBrew.RollOptions

  describe "get_default_options/0" do
    test "returns a RollOptions struct with default values" do
      default = RollOptions.get_default_options()

      assert default.explode == []
      assert default.explode_indefinite == []
      assert default.drop == 0
      assert default.keep == 0
      assert default.keeplowest == 0
      assert default.reroll == []
      assert default.reroll_indefinite == []
      assert default.target == 0
      assert default.failure == 0
    end
  end

  describe "RollOptions struct initialization" do
    test "can be initialized with default values" do
      roll_options = %RollOptions{}

      assert roll_options.explode == []
      assert roll_options.explode_indefinite == []
      assert roll_options.drop == 0
      assert roll_options.keep == 0
      assert roll_options.keeplowest == 0
      assert roll_options.reroll == []
      assert roll_options.reroll_indefinite == []
      assert roll_options.target == 0
      assert roll_options.failure == 0
    end

    test "allows overriding default values during initialization" do
      custom_options = %RollOptions{
        explode: [6],
        drop: 1,
        target: 15
      }

      assert custom_options.explode == [6]
      assert custom_options.explode_indefinite == []
      assert custom_options.drop == 1
      assert custom_options.keep == 0
      assert custom_options.keeplowest == 0
      assert custom_options.reroll == []
      assert custom_options.reroll_indefinite == []
      assert custom_options.target == 15
      assert custom_options.failure == 0
    end
  end
end
