defmodule Identicon do
  def main(input) do
    input
    |> convert_string
    |> color_picker
    |> grid_maker
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, name) do
    File.write("#{name}.png", image)
  end

  def draw_image(%Identicon.Image{grid: grid, color: color}) do
    image = :egd.create(250, 250)
    color = :egd.color(color)
    Enum.each(grid, fn([x, y]) -> 
      :egd.filledRectangle(image, x, y, color)
    end)
    :egd.render(image)
  end
  def grid_maker(%Identicon.Image{hex: hex} = list ) do
    grid = hex
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&mirror_list/1)
    |> List.flatten
    |> Enum.with_index
    |> Enum.filter(fn({number, _}) -> 
      rem(number, 2) == 0
    end)
    |> cordinate_setter

    %Identicon.Image{list | grid: grid } 
  end

  def cordinate_setter(cord) do
    cord
    |> Enum.map(fn({_,index}) -> 
      [{ div(index, 5)* 50 , rem(index,5) *50}, { (div(index, 5)* 50) + 50 , (rem(index,5) *50) + 50}]
    end)
  end

  def mirror_list(list) do
      [first, second | _ ] = list
      list ++ [second, first]
  end

  def color_picker(%Identicon.Image{hex: hex} = list) do
    [r,g,b |_] = hex
    %Identicon.Image{list | color: {r,g,b}}
  end

  def convert_string(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end
end
