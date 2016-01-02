defmodule C3Downloader.Download do
  require Logger
  alias C3Downloader.Parser

  defp download_file(url) when is_binary(url) do
    {:ok, resp} = :httpc.request(:get, {String.to_char_list(url), []}, [],
                                 [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp
    {:data, body}
  end

  defp download_html(url) when is_binary(url) do
    {:ok, resp} = :httpc.request(:get, {String.to_char_list(url), []}, [], [])
    {{_, 200, 'OK'}, _headers, body} = resp
    List.to_string(body)
  end

  defp get_filename(url), do: List.last(String.split(url, "/"))

  def write_file(path, filename, data) do
    full_path = path <> filename

    File.write full_path, data, [:exclusive]
  end

  def start_download(url, path, wait_time \\ 3_600_000) do
    filename = get_filename(url)
    full_path = path <> filename
    Logger.info "Starting '#{filename}'"

    if File.exists?(full_path) do
      {:exists, filename}
    else
      dl = Task.Supervisor.async(C3Downloader.DownloadSupervisor,
        fn -> download_file(url) end)
    {:data, data} = Task.await(dl, wait_time)
    {write_file(path, filename, data), filename}
    end
  end

  defp inform_done({:exists, filename}) do
    Logger.info "'#{filename}' already exists."
  end

  defp inform_done({:ok, filename}) do
    Logger.info "'#{filename}' downloaded."
  end

  defp download_chunk(chunk, download_path) do
    me = self
    chunk
    |> Enum.map(fn url -> spawn_link(fn -> send(me, start_download(url, download_path)) end) end)
    |> Enum.each(fn _ -> receive do result -> inform_done(result) end end)
end

  def download_mp4s(url, download_path, chunk_size \\ 2) do
    html_data = download_html(url)
    html_data
    |> Parser.find_mp4s(url)
    |> Enum.chunk(chunk_size)
    |> Enum.each(&(download_chunk(&1, download_path)))
  end
end
