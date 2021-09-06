defmodule Cardanoex.KeyTest do
  use ExUnit.Case
  doctest Cardanoex.Key
  alias Cardanoex.Key
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "get account public key" do
    test "get account public key successfully", %{wallet: wallet} do
      use_cassette "get_account_public_key_successfully" do
        {:ok, public_key} = Key.get_account_public_key(wallet.id)
        IO.inspect public_key
        assert public_key != nil
      end
    end
  end
end
