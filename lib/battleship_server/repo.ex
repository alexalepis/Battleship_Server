defmodule BattleshipServer.Repo do
  use Ecto.Repo, otp_app: :battleship_server, adapter: Tds.Ecto
end
