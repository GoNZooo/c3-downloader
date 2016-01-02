defmodule C3Downloader.Parser do
  require Logger

  defp filter_english(links) do
    Enum.filter(links, &(Regex.match?(~r/32c3-\d{4}-en/, &1)))
  end

  def find_mp4s(data, url) do
    Floki.find(data, "tr a")
    |> Floki.attribute("href")
    |> Enum.filter(&(String.contains?(&1, ".mp4")))
    |> filter_english
    |> Enum.map(&(url <> &1))
  end
end
