Benchmark

Benchmark run from 2023-10-05 02:33:07.941799Z UTC

## System

Benchmark suite executing on the following system:

<table style="width: 1%">
  <tr>
    <th style="width: 1%; white-space: nowrap">Operating System</th>
    <td>Linux</td>
  </tr><tr>
    <th style="white-space: nowrap">CPU Information</th>
    <td style="white-space: nowrap">AMD Ryzen Threadripper 1900X 8-Core Processor</td>
  </tr><tr>
    <th style="white-space: nowrap">Number of Available Cores</th>
    <td style="white-space: nowrap">16</td>
  </tr><tr>
    <th style="white-space: nowrap">Available Memory</th>
    <td style="white-space: nowrap">31.29 GB</td>
  </tr><tr>
    <th style="white-space: nowrap">Elixir Version</th>
    <td style="white-space: nowrap">1.15.4</td>
  </tr><tr>
    <th style="white-space: nowrap">Erlang Version</th>
    <td style="white-space: nowrap">26.0.2</td>
  </tr>
</table>

## Configuration

Benchmark suite executing with the following configuration:

<table style="width: 1%">
  <tr>
    <th style="width: 1%">:time</th>
    <td style="white-space: nowrap">30 s</td>
  </tr><tr>
    <th>:parallel</th>
    <td style="white-space: nowrap">1</td>
  </tr><tr>
    <th>:warmup</th>
    <td style="white-space: nowrap">5 s</td>
  </tr>
</table>

## Statistics



__Input: anxiety__

Run Time

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>

  <tr>
    <td style="white-space: nowrap">saxy</td>
    <td style="white-space: nowrap; text-align: right">140.66</td>
    <td style="white-space: nowrap; text-align: right">7.11 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;4.15%</td>
    <td style="white-space: nowrap; text-align: right">7.08 ms</td>
    <td style="white-space: nowrap; text-align: right">8.07 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">51.88</td>
    <td style="white-space: nowrap; text-align: right">19.27 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;6.46%</td>
    <td style="white-space: nowrap; text-align: right">19.07 ms</td>
    <td style="white-space: nowrap; text-align: right">24.65 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">44.46</td>
    <td style="white-space: nowrap; text-align: right">22.49 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;3.88%</td>
    <td style="white-space: nowrap; text-align: right">22.29 ms</td>
    <td style="white-space: nowrap; text-align: right">26.27 ms</td>
  </tr>

</table>


Run Time Comparison

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">saxy</td>
    <td style="white-space: nowrap;text-align: right">140.66</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">51.88</td>
    <td style="white-space: nowrap; text-align: right">2.71x</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">44.46</td>
    <td style="white-space: nowrap; text-align: right">3.16x</td>
  </tr>

</table>



Memory Usage

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Factor</th>
  </tr>
  <tr>
    <td style="white-space: nowrap">saxy</td>
    <td style="white-space: nowrap">2.87 MB</td>
    <td>&nbsp;</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap">18.54 MB</td>
    <td>6.46x</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap">19.35 MB</td>
    <td>6.74x</td>
  </tr>
</table>