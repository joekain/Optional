defmodule Optional do
  def map({:ok, value}, f), do: {:ok, f.(value)}
  def map(:error, _f), do: :error
  def map({:error, reason}, _f), do: {:error, reason}

  def flat_map(:error, _f), do: :error
  def flat_map({:error, reason}, _f), do: {:error, reason}
  def flat_map({:ok, value}, f), do: f.(value)

  def get_or_else(:error, default), do: default
  def get_or_else({:error, _reason}, default), do: default
  def get_or_else({:ok, value}, _default), do: value

  # Is this the best solution?  I don't like that the map produces
  # {:ok, {:ok, value}} only to have the outer tuple stripped by get_or_else.
  def or_else(v, ob), do: map(v, fn (any) -> {:ok, any} end) |> get_or_else(ob)

  def filter(v, f) do
    flat_map(v, fn (x) -> if f.(x), do: {:ok, x}, else: :error end)
  end

  def map2(a, b, f), do: flat_map(a,
    fn (aa) ->
      map(b, fn (bb) -> f.(aa, bb) end)
    end
  )

  def traverse(l, f), do: List.foldr(l, {:ok, []}, fn (x, acc) ->
      map2(f.(x), acc, fn (h, t) -> [h | t] end)
    end
  )

  def sequence(l), do: traverse(l, fn (x) -> x end)
end
