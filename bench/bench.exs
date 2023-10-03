defmodule Benchmark do
  def main() do
    bechmark = %{
      "saxaboom saxy" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :saxy),
      "saxaboom xmerl" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :xmerl),
      "saxaboom erlsom" => &Saxaboom.parse(&1, %ITunesRSS{}, adapter: :erlsom),
    }

    Benchee.run(bechmark,
      warmup: 5,
      time: 30,
      memory_time: 1,
      inputs: [anxiety: File.read!("data/anxiety.rss")],
      formatters: [
        Benchee.Formatters.Console
      ]
    )
  end
end

Benchmark.main
