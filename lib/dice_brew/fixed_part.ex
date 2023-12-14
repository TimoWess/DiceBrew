defmodule DiceBrew.FixedPart do
  alias DiceBrew.Parser

  @type t :: %__MODULE__{
          label: String.t(),
          value: integer(),
          sign: Parser.sign()
        }

  defstruct label: "", value: 0, sign: :plus

  @spec get_value(t()) :: integer()
  def get_value(%__MODULE__{value: value}), do: value
end
