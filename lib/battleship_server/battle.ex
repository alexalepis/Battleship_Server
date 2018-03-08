defmodule Battle do
  use GenServer

  def start_link(game_data) do
    GenServer.start_link(__MODULE__, game_data)
  end

  def init(%{game_id: new_game_id, player1: pl1, player2: pl2}) do
    game =
      Game.new(new_game_id, Game.Settings.new())
      |> Game.add_player(1, pl1)
      |> Game.add_player(1, pl2)

    player1 = Player.place_random(game.current_player)
    player2 = Player.place_random(game.enemy_player)

    game = %{game | current_player: player1, enemy_player: player2}

    {:ok, game}
  end

  def next_move(battle, x, y) do
    GenServer.call(battle, {:next_move, x, y})
  end

  def handle_call({:next_move, x, y}, _from, game) do
    move_result = Game.make_move(game, x, y) |> IO.inspect()

    case move_result do
      {:error, game, :game_ended} -> IO.puts(" game_ended")
      {:error, game, :out_of_bounds} -> IO.puts(" out_of_bounds")
      {:error, game, :already_shot} -> IO.puts(" already_shot")
      {:ok, game, :miss} -> IO.puts(" miss")
      {:ok, game, :winner_enemy} -> IO.puts(" winner_enemy")
      {:ok, game, :no_winner} -> IO.puts(" no_winner")
    end

    {:reply, game, game}
  end
end
