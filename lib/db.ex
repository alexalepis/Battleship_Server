defmodule Battleshipserver.Db.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game" do
    field(:game_id, :integer)
    field(:player1_username, :string)
    field(:player2_username, :string)
    field(:winner, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
  end

  @required_fields ~w(game_id player1_username player2_username start_date)a
  @optional_fields ~w(winner end_date)a

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
