defmodule DiceBrew.RollOptions do
  @type t :: %__MODULE__{
          explode: [integer()],
          explode_indefinite: [integer()],
          drop: integer(),
          keep: integer(),
          keeplowest: integer(),
          reroll: [integer()],
          reroll_indefinite: [integer()],
          target: integer(),
          failure: integer()
        }

  defstruct explode: [],
            explode_indefinite: [],
            drop: 0,
            keep: 0,
            keeplowest: 0,
            reroll: [],
            reroll_indefinite: [],
            target: 0,
            failure: 0

  def get_default_options() do
    %__MODULE__{}
  end
end
