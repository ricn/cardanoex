ExUnit.start()

ExUnit.after_suite(fn _ ->
  {:ok, all_wallets} = Wallet.list()

  Enum.each(all_wallets, fn w ->
    Wallet.delete(w.id)
  end)
end)
