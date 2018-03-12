defmodule Battle do
  use GenServer

  def start_link(game_data) do
    GenServer.start_link(__MODULE__, game_data)
  end

  def init(game_data) do
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

      player1 |> IO.inspect
      player2 |> IO.inspect
      Server.Protocol.send_to(player1.id, {:init_data, player1.my_board})
      Server.Protocol.send_to(player2.id, {:init_data, player2.my_board})

      %{game | current_player: player1, enemy_player: player2}
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
      {:error, _, :game_ended}    -> Server.Protocol.send_to(game.current_player.id, game.enemy_player.id, message)
      {:error, _, :out_of_bounds} -> Server.Protocol.send_to(game.current_player.id, message)
      {:error, _, :already_shot}  -> Server.Protocol.send_to(game.current_player.id, message)
      {:ok, _, :miss}             -> Server.Protocol.send_to(game.current_player.id, message)
                                     Server.Protocol.send_to(game.enemy_player.id, :your_turn)
      {:ok, _, :winner}           -> Server.Protocol.send_to(game.current_player.id, game.enemy_player.id, {message, game.enemy_player.name})
      {:ok, _, :hit}              -> Server.Protocol.send_to(game.current_player.id, game.enemy_player.id, {message, game.current_player.name})
                                     Server.Protocol.send_to(game.enemy_player.id, :your_turn)

    end

    new_game

  end



  def handle_info({:make_move, x, y, caller_id},  state) do

    case state.current_player.id == caller_id do
      true -> state = next_move(state, x, y)
      false -> Server.Protocol.send_to(caller_id, :not_your_turn)
    end

    {:noreply, state}
  end

end
