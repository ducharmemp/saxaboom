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

      {name, content}
    end)


    bechmark = %{
      "gluttony" => &Gluttony.parse_string/1,
      # "feed_raptor" => &Feedraptor.parse/1,
      # "feeder_ex" => &FeederEx.parse/1,
      "saxaboom saxy" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :saxy),
      "saxaboom xmerl" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :xmerl),
    }

    Benchee.run(bechmark,
      warmup: 5,
      time: 30,
      memory_time: 1,
      inputs: files,
      formatters: [
        Benchee.Formatters.Console
      ],
    )
  end
end

Benchmark.main
