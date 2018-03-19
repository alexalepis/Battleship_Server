defmodule BattleshipServer.Repo.Migrations.InitDb do
  use Ecto.Migration

  def change do
    create table(:game) do
      add :game_id, :integer
      add :player1_username, :string
      add :player2_username, :string
      add :winner, :string
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
    end
  end
end
