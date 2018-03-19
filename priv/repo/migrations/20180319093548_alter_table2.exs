defmodule BattleshipServer.Repo.Migrations.AlterTable2 do
  use Ecto.Migration

  def change do
     alter table(:game) do
      modify :start_date, :naive_datetime
      modify :end_date, :naive_datetime  
      end
  end
end
