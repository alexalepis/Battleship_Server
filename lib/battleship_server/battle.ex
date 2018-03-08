defmodule Battle do
  use GenServer

  def start_link(game_data) do
    GenServer.start_link(__MODULE__, game_data)
  end

  def init(game_data = %{game_id: new_game_id, player1: pl1, player2: pl2}) do
  data = data_init(game_data)
    {:ok, data} 
  end

  def data_init(%{game_id: new_game_id, player1: pl1, player2: pl2}) do
  
     game =
      Game.new(new_game_id, Game.Settings.new())
      |> Game.add_player(1, pl1)
      |> Game.add_player(1, pl2)

      player1 = Player.place_random(game.current_player)
      player2 = Player.place_random(game.enemy_player)

      game = %{game | current_player: player1, enemy_player: player2}
  end

  def next_move(battle, x, y) do
    GenServer.call(battle, {:next_move, x, y})
  end

  def handle_call({:next_move, x, y}, _from, game) do
    {status, new_game, message} = Game.make_move(game, x, y)
    case {status, new_game, message} do
      {:error, new_game, :game_ended} -> IO.puts(" game_ended")
      {:error, new_game, :out_of_bounds} -> IO.puts(" out_of_bounds")
      {:error, new_game, :already_shot} -> IO.puts(" already_shot")
      {:ok, new_game, :miss} -> IO.puts(" miss")
      {:ok, new_game, :winner_enemy} -> IO.puts(" winner_enemy")
      {:ok, new_game, :no_winner} -> IO.puts(" no_winner")
    end

    {:reply, new_game, new_game}
  end
end
