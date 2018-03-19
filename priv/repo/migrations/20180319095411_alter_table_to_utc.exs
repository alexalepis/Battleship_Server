defmodule BattleshipServer.Repo.Migrations.AlterTableToUtc do
  use Ecto.Migration

  def change do
      alter table(:game) do
        modify :start_date, :naive_datetime
        modify :end_date, :naive_datetime  
      end
  end
end
