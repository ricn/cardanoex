defmodule Cardano.WalletTest do
  use ExUnit.Case
  doctest Cardano.Wallet
  alias Cardano.Wallet

  describe "create wallets" do
    test "create wallet successfully" do
      name = "wallet #1"
      mnemonic = String.split(Mnemonic.generate(), " ")
      passphrase = "Super_Sekret3.14!"

      {:ok, wallet} =
        Wallet.create_wallet(name: name, mnemonic_sentence: mnemonic, passphrase: passphrase)

      assert wallet
    end

    test "create wallet successfully with mnemonic_second_factor" do
      name = "wallet #1"
      mnemonic1 = String.split(Mnemonic.generate(), " ")
      mnemonic2 = String.split(Mnemonic.generate(), " ")
      passphrase = "Super_Sekret3.14!"

      {:ok, wallet} =
        Wallet.create_wallet(
          name: name,
          mnemonic_sentence: mnemonic1,
          passphrase: passphrase,
          mnemonic_second_factor: mnemonic2
        )

      assert wallet
    end

    test "create wallet successfully with custom address_pool_gap" do
      name = "wallet #1"
      mnemonic = String.split(Mnemonic.generate(), " ")
      passphrase = "Super_Sekret3.14!"

      {:ok, wallet} =
        Wallet.create_wallet(
          name: name,
          mnemonic_sentence: mnemonic,
          passphrase: passphrase,
          address_pool_gap: 1000
        )

      assert wallet["address_pool_gap"] == 1000
    end

    test "try create wallet with bad mnemonic" do
      name = "wallet #1"
      mnemonic = String.split("one two three", " ")
      passphrase = "Super_Sekret3.14!"

      {:error, message} =
        Wallet.create_wallet(name: name, mnemonic_sentence: mnemonic, passphrase: passphrase)

      assert "Error in $['mnemonic_sentence']: Invalid number of words: 15, 18, 21 or 24 words are expected." ==
               message
    end

    test "try create wallet with weak passphrase" do
      name = "wallet #1"
      mnemonic = String.split(Mnemonic.generate(), " ")
      passphrase = "1"

      {:error, message} =
        Wallet.create_wallet(name: name, mnemonic_sentence: mnemonic, passphrase: passphrase)

      assert "Error in $.passphrase: passphrase is too short: expected at least 10 characters" ==
               message
    end

    test "try create wallet with no name" do
      name = nil
      mnemonic = String.split(Mnemonic.generate(), " ")
      passphrase = "Super_Sekret3.14!"

      {:error, message} =
        Wallet.create_wallet(name: name, mnemonic_sentence: mnemonic, passphrase: passphrase)

      assert "Error in $.name: parsing WalletName failed, expected String, but encountered Null" ==
               message
    end
  end

  describe "fetch wallets" do
    test "fetch wallet successfully" do
      {:ok, created_wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!"
        )

      {:ok, fetched_wallet} = Wallet.fetch(created_wallet["id"])
      assert created_wallet["id"] == fetched_wallet["id"]
    end

    test "try fetch wallet with invalid id" do
      {:error, message} = Wallet.fetch("abc-123")
      assert "wallet id should be a hex-encoded string of 40 characters" == message
    end

    test "try fetch wallet with correctly formatted id but non existent" do
      {:error, message} = Wallet.fetch("511b0ff88918401c119d3c6ccd4156e53444b5f0")

      assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" ==
               message
    end
  end

  describe "list wallets" do
    test "list all wallets successfully" do
      {:ok, _} =
        Wallet.create_wallet(
          name: "a wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!"
        )

      {:ok, result} = Wallet.list()

      assert Enum.any?(result, fn w ->
               w["name"] == "a wallet"
             end)
    end
  end

  describe "delete wallets" do
    test "delete wallet successfully" do
      {:ok, wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!"
        )

      {:ok, _} = Wallet.fetch(wallet["id"])
      # TODO: We can do better here?
      {:ok, _} = Wallet.delete(wallet["id"])
      {:error, message} = Wallet.fetch(wallet["id"])
      assert "I couldn't find a wallet with the given id: #{wallet["id"]}" == message
    end

    test "try delete wallet with invalid id" do
      {:error, message} = Wallet.delete("abc-123")
      assert "wallet id should be a hex-encoded string of 40 characters" == message
    end

    test "try delete wallet with correctly formatted id but non existent" do
      {:error, message} = Wallet.delete("511b0ff88918401c119d3c6ccd4156e53444b5f0")
      assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" == message
    end
  end

  describe "utxo stats" do
    test "fetch successfully" do
      {:ok, wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!"
        )

      {:ok, utox_stats} = Wallet.fetch_utxo_stats(wallet["id"])
      assert utox_stats["distribution"] != nil
    end

    test "try fetch with invalid id" do
      {:error, message} = Wallet.fetch_utxo_stats("abc-123")
      assert "wallet id should be a hex-encoded string of 40 characters" == message
    end

    test "try fetch with correctly formatted id but non existent" do
      {:error, message} = Wallet.fetch_utxo_stats("511b0ff88918401c119d3c6ccd4156e53444b5f0")
      assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" == message
    end
  end

  describe "update metadata" do
    test "update metadata successfully" do
      {:ok, created_wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!")

      {:ok, updated_wallet} = Wallet.update(created_wallet["id"], "My wallet")
      assert created_wallet["id"] == updated_wallet["id"]
      assert "My wallet" == updated_wallet["name"]
    end

    test "try update metadata with no name" do
      {:ok, created_wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!")

      {:error, message} = Wallet.update(created_wallet["id"], "")
      assert "Error in $.name: name is too short: expected at least 1 character" == message
    end

    test "try update with invalid wallet id" do
      {:error, message} = Wallet.update("abc-123", "Wallet")
      assert "wallet id should be a hex-encoded string of 40 characters" == message
    end

    test "try update with correctly formatted id but non existent" do
      {:error, message} = Wallet.update("511b0ff88918401c119d3c6ccd4156e53444b5f0", "Wallet")
      assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" == message
    end
  end

  describe "update passphrase" do
    test "update passphrase successfully" do
      passphrase = "Super_Sekret3.14!"
      {:ok, created_wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: passphrase)

      {:ok, _} = Wallet.update_passphrase(created_wallet["id"], passphrase, "New_Super_Sekret_6.28!")

      {:ok, updated_wallet} = Wallet.fetch(created_wallet["id"])
      assert created_wallet["passphrase"]["last_updated_at"] != updated_wallet["passphrase"]["last_updated_at"]
    end

    test "try update passphrase when old passphrase is incorrect" do
      {:ok, wallet} =
        Wallet.create_wallet(
          name: "wallet",
          mnemonic_sentence: String.split(Mnemonic.generate(), " "),
          passphrase: "Super_Sekret3.14!")

      {:error, message} = Wallet.update_passphrase(wallet["id"], "Wrong Old Password!123", "New_Super_Sekret_6.28!")
      wid = wallet["id"]
      assert "The given encryption passphrase doesn't match the one I use to encrypt the root private key of the given wallet: #{wid}" == message
    end
  end
end
