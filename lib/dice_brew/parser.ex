defmodule DiceBrew.Parser do
  alias DiceBrew.RollOptions
  alias DiceBrew.RollPart
  alias DiceBrew.FixedPart

  @notation_pattern ~r/^((?:(?:[+-])?(?:(?:\d+[dD]\d+(?:(?:[X!](?:\d+)|[X!])?)|(?:\d+))))+(?:\[[\w\d\s_-]+\])?)+$/
  @single_notation ~r/(?:(?:[+-])?(?:(?:\d+[dD]\d+(?:(?:[X!](?:\d+)|[X!])?)|(?:\d+))))+(?:\[[\w\d\s_-]+\])?/
  @single_part ~r/(?:([+-])?(?:(?:(\d+)[dD](\d+)((?:[X!](\d+))|(?:[X!]))?)|(\d+)))/
  @label ~r/\[[\w\d\s_-]+\]/

  @type dice_throw() :: String.t()
  @type sign() :: :plus | :minus
  @type roll_part() :: RollPart.t()
  @type fixed_part() :: FixedPart.t()
  @type part() :: roll_part() | fixed_part()
  @type part_group() :: {String.t(), [part()]}

  @spec string_to_sign(String.t()) :: sign()
  defp string_to_sign(""), do: :plus
  defp string_to_sign("+"), do: :plus
  defp string_to_sign("-"), do: :minus

  @spec is_roll_part(roll_part() | any()) :: boolean()
  def is_roll_part(%RollPart{}), do: true
  def is_roll_part(_), do: false

  @spec is_fixed_part(fixed_part() | any()) :: boolean()
  def is_fixed_part(%FixedPart{}), do: true
  def is_fixed_part(_), do: false

  @spec sanitise_dice(dice_throw()) :: dice_throw()
  defp sanitise_dice(dice) do
    dice
    |> String.trim()
  end

  @spec parse(dice_throw()) :: {:error, String.t()} | {:ok, [part_group()]}
  def parse(dice) do
    sanitized_dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, sanitized_dice) == [] do
      {:error, "Pattern does not match dice notation rules!"}
    else
      {:ok, Regex.scan(@single_notation, sanitized_dice) |> Enum.map(&_parse/1)}
    end
  end

  @spec parse!(dice_throw()) :: [part_group()]
  def parse!(dice) do
    sanitized_dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, sanitized_dice) == [],
      do: raise(ArgumentError, "Pattern does not match dice notation rules!")

    Regex.scan(@single_notation, sanitized_dice) |> Enum.map(&_parse/1)
  end

  @spec _parse([String.t()]) :: part_group()
  defp _parse([whole_part]) do
    label_match = Regex.run(@label, whole_part)
    label = if label_match == nil, do: "", else: hd(label_match)

    parts =
      Regex.scan(@single_part, whole_part)
      |> Enum.map(fn part ->
        convert_string_part_to_struct(part)
        |> apply_label(label)
      end)

    {label, parts}
  end

  @spec convert_string_part_to_struct([String.t()]) :: RollPart.t()
  defp convert_string_part_to_struct([_part, sign, amount, sides]) do
    amount = Integer.parse(amount) |> elem(0)
    sides = Integer.parse(sides) |> elem(0)
    sign = string_to_sign(sign)

    %RollPart{
      amount: amount,
      sides: sides,
      sign: sign
    }
  end

  @spec convert_string_part_to_struct([String.t()]) :: RollPart.t()
  defp convert_string_part_to_struct([_part, sign, amount, sides, _explode]) do
    amount = Integer.parse(amount) |> elem(0)
    sides = Integer.parse(sides) |> elem(0)
    sign = string_to_sign(sign)

    options = %RollOptions{explode_indefinite: [sides]}

    %RollPart{
      amount: amount,
      sides: sides,
      sign: sign,
      options: options
    }
  end

  @spec convert_string_part_to_struct([String.t()]) :: RollPart.t()
  defp convert_string_part_to_struct([_part, sign, "", "", "", "", value]) do
    sign = string_to_sign(sign)
    num = Integer.parse(value) |> elem(0)

    value =
      case sign do
        :plus -> num
        :minus -> -num
      end

    %FixedPart{
      value: value,
      sign: sign
    }
  end

  @spec convert_string_part_to_struct([String.t()]) :: RollPart.t()
  defp convert_string_part_to_struct([_part, sign, amount, sides, _explode, explode_value]) do
    amount = Integer.parse(amount) |> elem(0)
    sides = Integer.parse(sides) |> elem(0)
    explode_value = Integer.parse(explode_value) |> elem(0)
    sign = string_to_sign(sign)

    options = %RollOptions{explode_indefinite: Enum.to_list(explode_value..sides)}

    %RollPart{
      amount: amount,
      sides: sides,
      sign: sign,
      options: options
    }
  end

  @spec apply_label(RollPart.t(), String.t()) :: RollPart.t()
  defp apply_label(%RollPart{} = roll_part, label) do
    %RollPart{roll_part | label: label}
  end

  @spec apply_label(FixedPart.t(), String.t()) :: FixedPart.t()
  defp apply_label(%FixedPart{} = fixed_part, label) do
    %FixedPart{fixed_part | label: label}
  end
end
