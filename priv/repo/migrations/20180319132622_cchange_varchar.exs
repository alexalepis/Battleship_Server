defmodule BattleshipServer.Repo.Migrations.CchangeVarchar do
  use Ecto.Migration

  def change do
    alter table(:game) do
      modify :player1_username, :string
      modify :player2_username, :string
      modify :winner, :string

    end
  end
end
