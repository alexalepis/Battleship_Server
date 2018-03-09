defmodule Game.Server do
  use GenServer

  defstruct [:wait_list, :games]

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :game_server)
  end

  def init(_) do
    # games : %{ game_id => %{game_pid: nil, game_id: new_game_id, player1: state.wait_list, player2: username, winner: nil}}
     Node.set_cookie(Node.self, :"test")

    state = %Game.Server{wait_list: nil, games: Map.new()}
    {:ok, state}
  end

  def handle_info({:join_game, username,client_node, client_pid}, state) do
    IO.puts "#{username} has joined!"
    GenServer.cast(client_pid, :wait)
    #join_player(username, client_node, client_pid)
    {:noreply, state}
  end

  def join_player(username, node, client_pid) do
    case GenServer.call(:game_server, {:join, username}) do
       :alone -> Process.send(client_pid , :wait, [])
        IO.puts("#{username} is waiting for other player")

      :not_unique ->
        IO.puts("username: #{username} already exists ")

      :error_new_game ->
        IO.puts("error at game creation")

      {:ok, new_game_pid} ->
        IO.puts("game created")
        new_game_pid
    end
  end


  def handle_call({:join, username}, _from, state) do
    with true <- is_unique?(state, username) do
      case Map.get(state, :wait_list) do
        nil -> {:reply, :alone, %{state | wait_list: username}}
        _ -> create_new_game(state, username)
      end
    else
      false -> {:reply, :not_unique, state}
    end
  end

  def is_unique?(state, username) do
    unique_at_games =
      Enum.any?(state.games, fn {_, value} ->
        Map.get(value, :player1) == username or Map.get(value, :player2) == username
      end)

    case unique_at_games or state.wait_list == username do
      true -> false
      false -> true
    end
  end

  # games : %{ game_id => %{game_pid: nil, game_id: new_game_id, player1: state.wait_list, player2: username, winner: nil}}
  def create_new_game(state, username) do
    with new_game_id = :erlang.unique_integer(),
         new_game_data = %{game_id: new_game_id, player1: state.wait_list, player2: username},
         {:ok, new_game_pid} <- Battle.Supervisor.new_game(new_game_data) do
      new_game = %{
        game_pid: new_game_pid,
        game_id: new_game_id,
        player1: state.wait_list,
        player2: username,
        winner: nil
      }

      state = %{state | wait_list: nil, games: Map.put(state.games, new_game_id, new_game)}
      {:reply, {:ok, new_game_pid}, state}
    end
  end
end
