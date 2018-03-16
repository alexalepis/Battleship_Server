defmodule BattleshipServer.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do  
    create table(:game) do
      add :game_id, :bigint
      add :player1_username, :string
      add :player2_username, :string
      add :winner, :string    

    end
  end
end
