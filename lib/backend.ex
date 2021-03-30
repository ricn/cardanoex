defmodule Cardano.Backend do

  def create_wallet(name, mnemonic, passphrase, mnemonic_2f \\ nil) do
    data = %{name: name, mnemonic_sentence: mnemonic, passphrase: passphrase}
    case Tesla.post(client(), "/wallets", data) do
      {:ok, result} -> response(result)
    end
  end

  defp response(result) do
    if result.status == 400 do
      {:error, result.body["message"]}
    else
      {:ok, result.body}
    end
  end

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "http://localhost:8090/v2"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
