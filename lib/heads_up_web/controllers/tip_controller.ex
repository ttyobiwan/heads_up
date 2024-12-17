defmodule HeadsUpWeb.TipController do
  use HeadsUpWeb, :controller

  alias HeadsUp.Tips

  def index(conn, _) do
    conn
    |> assign(:tips, Tips.list_tips())
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    conn
    |> assign(:tip, Tips.get_tip(String.to_integer(id)))
    |> render(:show)
  end
end
