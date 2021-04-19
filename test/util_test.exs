defmodule Cardanoex.UtilTest do
  use ExUnit.Case
  alias Cardanoex.Util

  describe "keys_to_atom" do
    test "convert map with string keys to atom" do
      map_with_string_keys = %{"key" => "value"}
      map_with_atoms = Util.keys_to_atom(map_with_string_keys)
      assert Map.has_key?(map_with_atoms, :key)
    end
  end

  describe "generate_mnemonic" do
    test "generate mnemonic successfully" do
      mnemonic = Util.generate_mnemonic()
      assert mnemonic != nil
    end
  end
end
