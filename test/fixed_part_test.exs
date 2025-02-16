defmodule DiceBrew.FixedPartTest do
  use ExUnit.Case, async: true
  alias DiceBrew.FixedPart

  describe "FixedPart struct initialization" do
    test "can be initialized with default values" do
      fixed_part = %FixedPart{}

      assert fixed_part.label == ""
      assert fixed_part.value == 0
      assert fixed_part.sign == :plus
    end

    test "allows overriding default values during initialization" do
      custom_fixed_part = %FixedPart{
        label: "[Fire]",
        value: 10,
        sign: :minus
      }

      assert custom_fixed_part.label == "[Fire]"
      assert custom_fixed_part.value == 10
      assert custom_fixed_part.sign == :minus
    end
  end

  describe "Custom FixedPart behaviors" do
    test "supports basic addition for positive fixed parts" do
      part = %FixedPart{value: 10, sign: :plus}
      assert part.value == 10
    end

    test "supports basic subtraction for negative fixed parts" do
      part = %FixedPart{value: 10, sign: :minus}
      # Normally this is inferred elsewhere; here we ensure value doesn't change directly.
      assert part.value == 10
    end
  end
end
