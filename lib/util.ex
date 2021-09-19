defmodule Cardanoex.Util do
  @moduledoc false
  @spec keys_to_atom(map()) :: map()
  def keys_to_atom(map) do
    Map.new(
      map,
      fn {k, v} ->
        v2 = convert(v)
        {String.to_atom("#{k}"), v2}
      end
    )
  end

  defp convert(v) do
    cond do
      is_map(v) -> keys_to_atom(v)
      v in [[nil], nil] -> nil
      is_list(v) -> Enum.map(v, fn o -> keys_to_atom(o) end)
      true -> v
    end
  end

  @spec generate_mnemonic(number()) :: [String.t()]
  def generate_mnemonic(strength \\ 256), do: String.split(Mnemonic.generate(strength), " ")
end
