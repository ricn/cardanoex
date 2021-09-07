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
        assert String.starts_with?(public_key, "acct_")
      end
    end
  end

  describe "get public key" do
    test "get public key successfully", %{wallet: wallet} do
      use_cassette "get_public_key_successfully" do
        role = "utxo_external"
        index = "1852"
        {:ok, public_key} = Key.get_public_key(wallet.id, role, index)
        assert String.starts_with?(public_key, "addr_")
      end
    end
  end

  describe "create account public key" do
    test "create account public key successfully", %{wallet: wallet} do
      use_cassette "create_account_public_key_successfully" do
        index = "2000H"
        passphrase = "Super_Sekret3.14!"
        format = "extended"
        purpose = "2000H"

        {:ok, public_key} =
          Key.create_account_public_key(wallet.id,
            passphrase: passphrase,
            index: index,
            format: format,
            purpose: purpose
          )

        assert String.starts_with?(public_key, "acct_")
      end
    end

    test "create account public key successfully without purspose", %{wallet: wallet} do
      use_cassette "create_account_public_key_successfully_without_purpose" do
        index = "2000H"
        passphrase = "Super_Sekret3.14!"
        format = "extended"

        {:ok, public_key} =
          Key.create_account_public_key(wallet.id,
            passphrase: passphrase,
            index: index,
            format: format
          )

        assert String.starts_with?(public_key, "acct_")
      end
    end
  end
end
