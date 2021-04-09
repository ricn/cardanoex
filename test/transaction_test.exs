defmodule Cardano.TransactionTest do
  use ExUnit.Case
  doctest Cardano.Transaction

  alias Cardano.Transaction
  alias Cardano.Wallet
  require Logger

  @wallet_id "5c70f4f4970cadb7d5ec927e634be355df964b52"

  setup_all do
    {:ok, wallet} =
      case Wallet.fetch(@wallet_id) do
        {:ok, wallet} ->
          {:ok, wallet}

        {:error, _} ->
          Wallet.create_wallet(wallet_attrs)
      end

    [wallet: wait_for_synced_wallet(wallet)]
  end

  defp wait_for_synced_wallet(wallet) do
    status = wallet.state.status

    if status == "syncing" do
      Logger.info(wallet.state)
      :timer.sleep(5000)
      {:ok, wallet} = Wallet.fetch(@wallet_id)
      wait_for_synced_wallet(wallet)
    end

    wallet
  end

  def wallet_attrs do
    [
      name: "wallet_with_funds",
      mnemonic_sentence: [
        "bulk",
        "alley",
        "fix",
        "bonus",
        "vendor",
        "exchange",
        "picture",
        "slam",
        "autumn",
        "multiply",
        "cool",
        "safe",
        "maze",
        "bean",
        "tourist",
        "drastic",
        "rent",
        "friend",
        "alcohol",
        "focus",
        "invite",
        "save",
        "usage",
        "maid"
      ],
      passphrase: "Super_Sekret3.14!"
    ]
  end

  describe "estimate fee" do
    test "estimate fee successfully", %{wallet: wallet} do

      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 42_000_000, unit: "lovelace"}
          }
        ]
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
    end
  end
end
