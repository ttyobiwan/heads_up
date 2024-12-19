defmodule HeadsUpWeb.BadgeComponents do
  use HeadsUpWeb, :html

  attr :status, :atom, required: true, values: [:pending, :resolved, :cancelled]

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      style_status(@status)
    ]}>
      {@status}
    </div>
    """
  end

  defp style_status(:pending), do: "text-amber-600 border-amber-600"
  defp style_status(:resolved), do: "text-lime-600 border-lime-600"
  defp style_status(:cancelled), do: "text-gray-600 border-gray-600"
end
