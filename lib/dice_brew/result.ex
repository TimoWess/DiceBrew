defmodule DiceBrew.Result do
  alias DiceBrew.Parser

  @type t :: %__MODULE__{
          label: String.t(),
          total: integer(),
          parts: [Parser.part()]
        }

  defstruct label: "", total: 0, parts: []

  @spec new(label: String.t(), total: integer(), parts: Parser.part()) :: t()
  def new(options \\ []) do
    struct(%__MODULE__{}, options)
  end

  @spec to_struct(map()) :: t()
  def to_struct(map) do
    struct(__MODULE__, map)
  end
end
