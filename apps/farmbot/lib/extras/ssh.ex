defmodule SSH do
  @moduledoc """
    Module to manage SSH via an Erlang port.
  """
  use GenServer
  require Logger
  @banner "/tmp/banner"
  @dropbear "/usr/sbin/dropbear"
  @cmd "dropbear -R -F -a -B -b #{@banner}"

  def init(:prod) do
    if File.exists? @dropbear do
      Process.flag(:trap_exit, true)
      make_banner
      {:ok, Port.open({:spawn, @cmd}, [:binary])}
    else
      {:ok, self()} # Just a hack.
    end
  end

  def init(_) do
    {:ok, nil}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def handle_info({:EXIT, port, reason}, state)
  when state == port do
    Logger.error ">>`s ssh client died: #{inspect reason}"
    new_state = Port.open({:spawn, @cmd}, [:binary])
    {:noreply, new_state}
  end

  def handle_info(_info, port) do
    {:noreply, port}
  end

  def terminate(_reason, _state) do
    save_contents
  end

  def save_contents do
    # Read from /tmp
    :ok
  end

  def make_banner do
    contents =
    """
    __________________________________________________________________
    | WELCOME TO FARMBOT SHELL. I AM TRULY SORRY YOU HAVE TO BE HERE |
    |_______________________________|________________________________|
    |       THERE IS NO $PATH       |        THERE IS NO BASH        |
    |         THERE IS NO SU        |       THERE IS NO APT-GET      |
    |        THERE IS NO MAKE       |        THERE IS NO WGET        |
    |_______________________________|________________________________|
    """
    File.write(@banner, contents)
  end
end
