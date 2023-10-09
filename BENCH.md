Benchmark

Benchmark run from 2023-10-09 02:17:20.575314Z UTC

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



__Input: anxiety_read__

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
    <td style="white-space: nowrap; text-align: right">161.35</td>
    <td style="white-space: nowrap; text-align: right">6.20 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;5.06%</td>
    <td style="white-space: nowrap; text-align: right">6.15 ms</td>
    <td style="white-space: nowrap; text-align: right">7.08 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">51.99</td>
    <td style="white-space: nowrap; text-align: right">19.23 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;6.22%</td>
    <td style="white-space: nowrap; text-align: right">19.17 ms</td>
    <td style="white-space: nowrap; text-align: right">22.68 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">46.61</td>
    <td style="white-space: nowrap; text-align: right">21.45 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;4.69%</td>
    <td style="white-space: nowrap; text-align: right">21.32 ms</td>
    <td style="white-space: nowrap; text-align: right">24.17 ms</td>
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
    <td style="white-space: nowrap;text-align: right">161.35</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">51.99</td>
    <td style="white-space: nowrap; text-align: right">3.1x</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">46.61</td>
    <td style="white-space: nowrap; text-align: right">3.46x</td>
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
    <td style="white-space: nowrap">2.73 MB</td>
    <td>&nbsp;</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap">18.46 MB</td>
    <td>6.76x</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap">19.20 MB</td>
    <td>7.03x</td>
  </tr>
</table>



__Input: anxiety_stream__

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
    <td style="white-space: nowrap; text-align: right">97.65</td>
    <td style="white-space: nowrap; text-align: right">10.24 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;4.34%</td>
    <td style="white-space: nowrap; text-align: right">10.21 ms</td>
    <td style="white-space: nowrap; text-align: right">11.30 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">47.61</td>
    <td style="white-space: nowrap; text-align: right">21.00 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;12.69%</td>
    <td style="white-space: nowrap; text-align: right">21.20 ms</td>
    <td style="white-space: nowrap; text-align: right">25.11 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">35.11</td>
    <td style="white-space: nowrap; text-align: right">28.48 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;14.53%</td>
    <td style="white-space: nowrap; text-align: right">28.67 ms</td>
    <td style="white-space: nowrap; text-align: right">40.52 ms</td>
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
    <td style="white-space: nowrap;text-align: right">97.65</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">47.61</td>
    <td style="white-space: nowrap; text-align: right">2.05x</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">35.11</td>
    <td style="white-space: nowrap; text-align: right">2.78x</td>
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
    <td style="white-space: nowrap">3.69 MB</td>
    <td>&nbsp;</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap">19.29 MB</td>
    <td>5.22x</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap">21.49 MB</td>
    <td>5.82x</td>
  </tr>
</table>