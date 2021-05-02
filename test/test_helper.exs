ExUnit.start()

ExUnit.after_suite(fn _ ->
  if !System.get_env("GITHUB_ACTIONS") do
    {:ok, all_wallets} = Cardanoex.Wallet.list()

    Enum.each(all_wallets, fn w ->
      if w.id != "5c70f4f4970cadb7d5ec927e634be355df964b52" do
        Cardanoex.Wallet.delete(w.id)
      end
    end)
  end
end)

defmodule TestHelpers do
  @wallet_id "5c70f4f4970cadb7d5ec927e634be355df964b52"
  alias Cardanoex.Wallet
  require Logger

  def setup_wallet_with_funds do
    {:ok, wallet} =
      case Wallet.fetch(@wallet_id) do
        {:ok, wallet} ->
          {:ok, wallet}

        {:error, _} ->
          Wallet.create_wallet(wallet_attrs())
      end

    wait_for_synced_wallet(wallet)
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

  defp wallet_attrs do
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
end
