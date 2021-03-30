defmodule Cardano.Wallet do
  alias Cardano.Backend

  def create_wallet(name, mnemonic_sentence, passphrase, mnemonic_second_factor \\ nil) do
    Backend.create_wallet(name, mnemonic_sentence, passphrase)
  end
end
