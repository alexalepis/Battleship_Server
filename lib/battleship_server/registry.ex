defmodule Registry do
    use GenServer

    

    def start_link(_) do
        GenServer.start_link(__MODULE__, nil, name: :registry)
    end

    def init(_) do
        {:ok, Map.new}
    end


    def fetch(game_id) do
        GenServer.call(:registry, {:fetch, game_id})
    end

    def update(game) do
        GenServer.cast(:registry, {:update, game})
    end

    def handle_cast({:update, game}, state) do
        {:noreply, Map.put(state, game.game_id, game)}
    end

    def handle_call({:fetch, game_id}, _from, state) do
        {:reply, Map.get(state, game_id), state}
    end


end