defmodule Cardanoex.AddressTest do
  use ExUnit.Case
  doctest Cardanoex.Address
  alias Cardanoex.Address
  alias Cardanoex.Wallet
  alias Cardanoex.Util
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  def wallet_attrs do
    [
      name: "wallet #1",
      mnemonic_sentence: Util.generate_mnemonic(),
      passphrase: "Super_Sekret3.14!"
    ]
  end

  describe "list addresses" do
    test "list addresses successfully" do
      use_cassette "list_addresses_successfully" do
        {:ok, wallet} = Wallet.create_wallet(wallet_attrs())
        {:ok, addresses} = Address.list(wallet.id)
        assert length(addresses) == 20
      end
    end

    test "try list addresses with invalid wallet id" do
      use_cassette "try_list_addresses_with_invalid_wallet_id" do
        {:error, message} = Address.list("abc-123")
        assert "wallet id should be a hex-encoded string of 40 characters" == message
      end
    end

    test "try list addresses with correctly formatted id but non existent" do
      use_cassette "try_list_addresses_with_correctly_formatted_id_but_non_existent" do
        {:error, message} = Address.list("511b0ff88918401c119d3c6ccd4156e53444b5f0")

        assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" ==
                 message
      end
    end
  end

  describe "inspect addresses" do
    test "inspect address successfully" do
      use_cassette "inspect_address_successfully" do
        {:ok, wallet} = Wallet.create_wallet(wallet_attrs())
        {:ok, addresses} = Address.list(wallet.id)
        {:ok, address} = Address.inspect(List.first(addresses)["id"])
        assert address != nil
      end
    end
  end
end
