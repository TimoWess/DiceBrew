defmodule DiceBrew.RollOptions do
  @type t :: %__MODULE__{
          explode: integer(),
          explode_indefinite: integer(),
          drop: integer(),
          keep: integer(),
          keeplowest: integer(),
          reroll: integer(),
          reroll_indefinite: integer(),
          target: integer(),
          failure: integer()
        }

  defstruct explode: 0,
            explode_indefinite: 0,
            drop: 0,
            keep: 0,
            keeplowest: 0,
            reroll: 0,
            reroll_indefinite: 0,
            target: 0,
            failure: 0
end
