defmodule Benchmark do
  def main() do
    data = [
      "anxiety",
      "ben",
      "daily",
      "dave",
      "stuff",
      "sleepy"
    ]

    files = Map.new(data, fn name ->
      content = "data/#{name}.rss"
      |> Path.expand(__DIR__)
      |> File.read!()

      {"#{name}_read", content}
    end)

    streams = Map.new(data, fn name ->
      content = "data/#{name}.rss"
      |> Path.expand(__DIR__)
      |> File.stream!()

      {"#{name}_stream", content}
    end)


    bechmark = %{
      "saxaboom saxy" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :saxy),
      "saxaboom xmerl" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :xmerl),
      "saxaboom erlsom" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :erlsom),
    }

    Benchee.run(bechmark,
      warmup: 5,
      time: 30,
      memory_time: 1,
      inputs: Map.merge(files, streams),
      formatters: [
        Benchee.Formatters.Console
      ]
    )
  end
end

Benchmark.main
