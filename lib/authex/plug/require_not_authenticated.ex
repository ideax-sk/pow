defmodule Authex.Plug.RequireNotAuthenticated do
  @moduledoc """
  This plug ensures that a user hasn't already been authenticated.

  Example:

    plug Authex.Plug.RequireAuthenticated,
      error_handler: MyAppWeb.Authex.ErrorHandler

  You can see `Authex.Phoenix.PlugErrorHandler` for an example of the error
  handler module.
  """
  alias Plug.Conn
  alias Authex.{Config, Plug}

  @spec init(Config.t()) :: Config.t()
  def init(config), do: config

  @spec call(Conn.t(), Config.t()) :: Conn.t()
  def call(conn, config) do
    conn
    |> Plug.current_user()
    |> maybe_halt(conn, config)
  end

  defp maybe_halt(nil, conn, _config), do: conn
  defp maybe_halt(_user, conn, config) do
    handler = Config.get(config, :error_handler, nil)

    case handler do
      nil ->
        Conn.halt(conn)

      handler ->
        conn
        |> handler.call(:already_authenticated)
        |> Conn.halt()
    end
  end
end
