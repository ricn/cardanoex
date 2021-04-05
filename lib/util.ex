defmodule Cardano.Util do
  def keys_to_atom(map) do
    Map.new(
     map,
     fn {k, v} ->
       v2 = cond do
         is_map(v) -> keys_to_atom(v)
         v in [[nil], nil] -> nil
         is_list(v) -> Enum.map(v, fn o -> keys_to_atom(o) end)
         true -> v
       end
       {String.to_atom("#{k}"), v2}
     end
    )
   end
end
