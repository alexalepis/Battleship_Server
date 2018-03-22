defmodule Server.Protocol do
  def send_to(client_pid, message) do
    Process.send(client_pid, message, [])
  end

  def send_to(client_pid_1, client_pid_2, message) do
    Process.send(client_pid_1, message, [])
    Process.send(client_pid_2, message, [])
  end
end
