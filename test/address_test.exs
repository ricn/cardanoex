defmodule Cardano.AddressTest do
  use ExUnit.Case
  doctest Cardano.Address
  alias Cardano.Address
  alias Cardano.Wallet

  def wallet_attrs do
    [
      name: "wallet #1",
      mnemonic_sentence: String.split(Mnemonic.generate(), " "),
      passphrase: "Super_Sekret3.14!"
    ]
  end

  describe "list addresses" do
    test "list addresses successfully" do
      {:ok, wallet} = Wallet.create_wallet(wallet_attrs())
      {:ok, addresses} = Address.list(wallet.id)
      assert length(addresses) == 20
    end

    test "try list addresses with invalid wallet id" do
      {:error, message} = Address.list("abc-123")
      assert "wallet id should be a hex-encoded string of 40 characters" == message
    end

    test "try list addresses with correctly formatted id but non existent" do
      {:error, message} = Address.list("511b0ff88918401c119d3c6ccd4156e53444b5f0")

      assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" ==
               message
    end
  end

  describe "inspect addresses" do
    test "inspect address successfully" do
      {:ok, wallet} = Wallet.create_wallet(wallet_attrs())
      {:ok, addresses} = Address.list(wallet.id)
      {:ok, address} = Address.inspect(List.first(addresses)["id"])
      assert address != nil
    end
  end
end
