defmodule Cardano.WalletTest do
  use ExUnit.Case
  doctest Cardano.Wallet
  alias Cardano.Wallet

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
