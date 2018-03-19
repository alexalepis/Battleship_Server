defmodule BattleshipServer.Repo.Migrations.AlterTableToUtc2 do
  use Ecto.Migration

  def change do
      alter table(:game) do
        modify :start_date, :utc_datetime
        modify :end_date, :utc_datetime  
      end
  end
end
