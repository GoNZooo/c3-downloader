# C3Downloader

Just a downloader for mp4s from the CCC.

Supports simultaneous downloads:

`C3Downloader.Downloader.download_mp4s(url, path, chunk_size \\ 2)`

The above function will split the list of mp4s into chunks the size
of `chunk_size` and download each file in each chunk simultaneously.
