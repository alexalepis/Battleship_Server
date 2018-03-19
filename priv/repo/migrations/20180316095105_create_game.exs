defmodule BattleshipServer.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do  
    alter table(:game) do
      add :start_date, :datetime
      add :end_date, :datetime  

    end
  end
end
