ExUnit.start()

ExUnit.after_suite(fn _ ->
  {:ok, all_wallets} = Cardano.Wallet.list()

  Enum.each(all_wallets, fn w ->
    if w.id != "5c70f4f4970cadb7d5ec927e634be355df964b52" do
      IO.inspect(w.id)
      Cardano.Wallet.delete(w.id)
    end
  end)
end)
