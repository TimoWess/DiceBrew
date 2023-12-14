defmodule DiceBrew.RollPart do
  alias DiceBrew.RollOptions
  alias DiceBrew.Parser

  @type t :: %__MODULE__{
          label: String.t(),
          amount: integer(),
          sides: integer(),
          tally: [integer()],
          total: integer(),
          exploded_total: integer(),
          sign: Parser.sign(),
          options: RollOptions.t(),
          exploding_series: list(),
          reroll_count: integer()
        }

  defstruct label: "",
            amount: 0,
            sides: 0,
            tally: [],
            total: 0,
            exploded_total: 0,
            sign: :plus,
            options: %RollOptions{},
            exploding_series: [],
            reroll_count: 0

  @spec get_tally(t()) :: [integer()]
  def get_tally(%__MODULE__{tally: tally}), do: tally
end
