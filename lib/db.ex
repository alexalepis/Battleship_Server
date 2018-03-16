defmodule Battleshipserver.Db.Game do
  use Ecto.Schema

  schema "game" do
    field :game_id, :integer
    field :player1_username, Tds.VarChar
    field :player2_username, Tds.VarChar
    field :winner, Tds.VarChar
  end
end
