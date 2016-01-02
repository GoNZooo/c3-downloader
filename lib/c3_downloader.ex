defmodule C3Downloader do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: C3Downloader.DownloadSupervisor]]),
      # Here you could define other workers and supervisors as children
      # worker(Wedding.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: C3Downloader.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
