defmodule BattleshipServer.Repo.Migrations.AlterTable do
  use Ecto.Migration

  def change do
     alter table(:game) do
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime  
      end
  end
end
