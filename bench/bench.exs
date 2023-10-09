defmodule Benchmark do
  def main() do
    bechmark = %{
      "saxy" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :saxy),
      "xmerl" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :xmerl),
      "erlsom" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :erlsom),
    }

    Benchee.run(bechmark,
      warmup: 5,
      time: 30,
      memory_time: 1,
      inputs: [anxiety_read: File.read!("data/anxiety.rss"), anxiety_stream: File.stream!("data/anxiety.rss")],
      formatters: [
        Benchee.Formatters.Console,
        {Benchee.Formatters.Markdown, file: "../BENCH.md"}
      ]
    )
  end
end

Benchmark.main
