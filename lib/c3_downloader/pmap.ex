defmodule C3Downloader.Pmap do
  def each(collection, f) do
    me = self
    Enum.each(fn e -> spawn_link(fn -> send me, {self, f.(e)} end) end)
  end
end
