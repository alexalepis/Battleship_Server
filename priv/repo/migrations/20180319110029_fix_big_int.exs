defmodule BattleshipServer.Repo.Migrations.FixBigInt do
  use Ecto.Migration

  def change do
    alter table(:game) do
      modify :game_id, :bigint
    end
  end
end
