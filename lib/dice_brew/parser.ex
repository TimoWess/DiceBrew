defmodule DiceBrew.Parser do
  alias DiceBrew.RollOptions
  alias DiceBrew.RollPart
  alias DiceBrew.FixedPart

  import Regex, only: [source: 1, compile!: 1]

  # Define all Regex Module Attributes for the parser
  @sign ~r/(?<sing>[+-])/
  @roll_part ~r/(?:(?<amount>\d+)?[dD](?<sides>\d+))/
  @fixed_part ~r/(?<fixed>\d+)/
  @explode ~r/(?:([X!])(?<explode_value>\d+)?)/
  @label ~r/(?<label>\[[\w\d\s_-]+\])/
  @single_part compile!(
                 "#{source(@sign)}?(?:(?:#{source(@roll_part)}#{source(@explode)}?)|#{source(@fixed_part)})"
               )
  @single_notation compile!("(#{source(@single_part)})+#{source(@label)}?")
  @notation_pattern compile!("^(#{source(@single_notation)})+$")

  @type dice_throw() :: String.t()
  @type sign() :: :plus | :minus
  @type roll_part() :: RollPart.t()
  @type fixed_part() :: FixedPart.t()
  @type part() :: roll_part() | fixed_part()
  @type label() :: String.t()
  @type part_group() :: {label(), [part()]}

  @spec string_to_sign(String.t()) :: sign()
  defp string_to_sign(""), do: :plus
  defp string_to_sign("+"), do: :plus
  defp string_to_sign("-"), do: :minus

  @spec is_roll_part(roll_part() | fixed_part()) :: boolean()
  def is_roll_part(%RollPart{}), do: true
  def is_roll_part(_), do: false

  @spec is_fixed_part(fixed_part() | roll_part()) :: boolean()
  def is_fixed_part(%FixedPart{}), do: true
  def is_fixed_part(_), do: false

  @spec sanitise_dice(dice_throw()) :: dice_throw()
  defp sanitise_dice(dice) do
    dice
    |> String.trim()
  end

  @spec parse(<<>>) :: {:error, String.t()}
  def parse("") do
    {:error, "Empty string provided"}
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
  defp _parse([whole_part | _xs]) do
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

  # Most basic roll part (e.g. 2d6 or d8)
  @spec convert_string_part_to_struct([String.t()]) :: roll_part()
  defp convert_string_part_to_struct([_part, sign, amount, sides]) do
    amount = if amount == "", do: 1, else: Integer.parse(amount) |> elem(0)
    sides = Integer.parse(sides) |> elem(0)
    sign = string_to_sign(sign)

    %RollPart{
      amount: amount,
      sides: sides,
      sign: sign
    }
  end

  # Any fixed part (e.g. 10 or -8)
  @spec convert_string_part_to_struct([String.t()]) :: fixed_part() 
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

  # Max value explode (e.g. 2d6X or d10!)
  @spec convert_string_part_to_struct([String.t()]) :: roll_part()
  defp convert_string_part_to_struct([_part, sign, amount, sides, _explode]) do
    amount = if amount == "", do: 1, else: Integer.parse(amount) |> elem(0)
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

  # Explode <explode_value> to sides (e.g. 2d6X5 or d10!8)
  @spec convert_string_part_to_struct([String.t()]) :: roll_part()
  defp convert_string_part_to_struct([_part, sign, amount, sides, _explode, explode_value]) do
    amount = if amount == "", do: 1, else: Integer.parse(amount) |> elem(0)
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

  @spec apply_label(roll_part(), String.t()) :: roll_part()
  defp apply_label(%RollPart{} = roll_part, label) do
    %RollPart{roll_part | label: label}
  end

  @spec apply_label(fixed_part(), String.t()) :: fixed_part()
  defp apply_label(%FixedPart{} = fixed_part, label) do
    %FixedPart{fixed_part | label: label}
  end
end
