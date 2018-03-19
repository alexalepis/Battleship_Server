defmodule Battleshipserver.Db.Game do
  use Ecto.Schema

  schema "game" do
    field :game_id, :integer
    field :player1_username, :string
    field :player2_username, :string
    field :winner, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
  end
end
