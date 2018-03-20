defmodule Server.Supervisor do
use Supervisor

    def start_link(_) do
        Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def init(_) do

    children = [
        Game.Server,
        BattleshipServer.Registry,
        BattleshipServer.Store
    ]
    opts = [strategy: :one_for_one]

    Supervisor.init(children, opts)    
    end

end