defmodule Cardano.TransactionTest do
  use ExUnit.Case
  doctest Cardano.Transaction

  alias Cardano.Transaction
  alias Cardano.Wallet

  def wallet_attrs do
    [
      name: "wallet_with_funds",
      mnemonic_sentence: ["bulk", "alley", "fix", "bonus", "vendor", "exchange", "picture", "slam", "autumn", "multiply", "cool", "safe", "maze", "bean", "tourist", "drastic", "rent", "friend", "alcohol", "focus", "invite", "save", "usage", "maid"],
      passphrase: "Super_Sekret3.14!"
    ]
  end

  describe "estimate fee" do
    test "estimate fee successfully" do
      {:ok, wallet} = Wallet.create_wallet(wallet_attrs())
      transaction = %{
        payments: [
          %{
            address: "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 42000000, unit: "lovelace"}
        }
          ]
      }
      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
    end
  end
end
