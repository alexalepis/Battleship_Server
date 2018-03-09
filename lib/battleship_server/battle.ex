defmodule Battle do
  use GenServer

  def start_link(game_data) do
    GenServer.start_link(__MODULE__, game_data)
  end

  def init(game_data = %{game_id: new_game_id, player1: pl1, player2: pl2}) do
    data = data_init(game_data)
    {:ok, data}
  end

  def data_init(%{game_id: new_game_id, player1: {pl1, pl1_node}, player2: {pl2, pl2_node}}) do

     game =
      Game.new(new_game_id, Game.Settings.new())
      |> Game.add_player(pl1_node, pl1)
      |> Game.add_player(pl2_node, pl2)

      player1 = Player.place_random(game.current_player)
      player2 = Player.place_random(game.enemy_player)

      game = %{game | current_player: player1, enemy_player: player2}
  end

  # def next_move(battle, x, y) do
  #   GenServer.call(battle, {:next_move, x, y})
  # end

  # def handle_call({:next_move, x, y}, _from, game) do
  #   {status, new_game, message} = Game.make_move(game, x, y)
  #   case {status, new_game, message} do
  #     {:error, new_game, :game_ended} -> IO.puts(" game_ended")
  #     {:error, new_game, :out_of_bounds} -> IO.puts(" out_of_bounds")
  #     {:error, new_game, :already_shot} -> IO.puts(" already_shot")
  #     {:ok, new_game, :miss} -> IO.puts(" miss")
  #     {:ok, new_game, :winner_enemy} -> IO.puts(" winner_enemy")
  #     {:ok, new_game, :no_winner} -> IO.puts(" no_winner")
  #   end

  #   {:reply, new_game, new_game}
  # end

  def next_move(game, x, y) do
    {status, new_game, message} = Game.make_move(game, x, y)
    case {status, new_game, message} do
      {:error, new_game, :game_ended} -> Process.send({:client, game.current_player.id}, message, [])
                                         Process.send({:client, game.enemy_player.id}, message, [])
      {:error, new_game, :out_of_bounds} -> Process.send({:client, game.current_player.id}, message, [])
      {:error, new_game, :already_shot} -> Process.send({:client, game.current_player.id}, message, [])
      {:ok, new_game, :miss} -> Process.send({:client, game.current_player.id}, message, [])
                                Process.send({:client, game.enemy_player.id}, :your_turn, [])
      {:ok, new_game, :winner} -> Process.send({:client, game.current_player.id}, {message, game.enemy_player.name}, [])
                                  Process.send({:client, game.enemy_player.id}, {message, game.enemy_player.name}, [])
      {:ok, new_game, :hit} -> Process.send({:client, game.current_player.id}, {message, game.enemy_player.name}, [])
                               Process.send({:client, game.enemy_player.id}, {message, game.enemy_player.name}, [])
                               Process.send({:client, game.enemy_player.id}, :your_turn, [])
    end

    new_game
  
  end



  def handle_info({:make_move, x, y, caller_id},  state) do


    case state.current_player.id == caller_id do
      true -> state = next_move(state, x, y)
      false -> Process.send({:client, caller_id}, :not_your_turn,[] )
    end
    # IO.puts " next move #{x} #{y}: game_data #{state.game_id}"
    # Process.send({:client, state.current_player.id}, {:move_completed, x, y},[] )
    # Process.send({:client, state.enemy_player.id}, {:move_completed, x, y},[] )

    {:noreply, state}
  end

end
