# DiceBrew: A Dice Parsing and Rolling Library for Elixir

## Usage

The main two modules you'll want from this Library are `DiceBrew.Parser` and `DiceBrew.Roller` which provide parsing and rolling functionality respectively. They don't use macros so you can simply alias them like so:

```elixir
alias DiceBrew.Parser
alias DiceBrew.Roller
```
For the most important functions, use `Parser.parse/1`, `Parser.parse!/1`, `Roller.roll/2` and `Roller.roll!/2`, which all expect a Dice Throw String that follows the format explained in the *Dice Throw String* section. The functions marked with an exclamation point will raise an ArgumentError if the provided String doesn't match the correct format, while the other functions return an `{:error, message}` tuple instead.

### Roll and Fixed Parts

The `parse` functions will (if a properly formatted String was provided) return a List of `{label_string, [part]}` tuples that are based on all parts that are before the first or in between two labels. The list of parts will contain all rolls (e.g., 2d6 or 1d8X) and fixed parts (e.g., +10 or -5) that are part of that labeled group.

#### Fixed Part Structure

A fixed part looks like this:

```elixir
%DiceBrew.FixedPart{
  label: "[Fire]",
  value: 5,
  sign: :plus
}
```

It's the most basic component of a dice throw.

#### Roll Part Structure

A roll part looks like this:

```elixir
%DiceBrew.RollPart{
  label: "[Fire]",
  amount: 1,
  sides: 8,
  tally: [],
  total: 0,
  exploded_total: 0,
  sign: :plus,
  options: %DiceBrew.RollOptions{
    explode: [],
    explode_indefinite: [8],
    drop: 0,
    keep: 0,
    keeplowest: 0,
    reroll: [],
    reroll_indefinite: [],
    target: 0,
    failure: 0
  },
  exploding_series: [],
  reroll_count: 0
}
```
The additional options for rerolling and exploding dice are saved in the `RollOptions` struct. All fields that are tied to rolling the part, like total, tally or exploding_series are evaluted using the`Roller` module.

### Result and PartialResult

The `roll` and `roll!` functions return a `DiceBrew.Result` struct that contains the total of the roll, an optional label and a List of `DiceBrew.PartialResult` structs that each contains information about each labeled part in the roll. The partial results have the same sturcture as the normal result except that they provide a list of parts instead of more partial results.
Given the multiple optional values of the input for the parser, it opts not to retain the original input string alongside the rest of the data. Instead, a uniformly formatted string can be generated using the `DiceBrew.StringBuilder` module.
