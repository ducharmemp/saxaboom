Benchmark

Benchmark run from 2023-10-15 16:51:10.551020Z UTC

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
    <td style="white-space: nowrap; text-align: right">143.57</td>
    <td style="white-space: nowrap; text-align: right">6.97 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;9.31%</td>
    <td style="white-space: nowrap; text-align: right">6.75 ms</td>
    <td style="white-space: nowrap; text-align: right">8.93 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">52.52</td>
    <td style="white-space: nowrap; text-align: right">19.04 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;7.95%</td>
    <td style="white-space: nowrap; text-align: right">18.66 ms</td>
    <td style="white-space: nowrap; text-align: right">24.76 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">42.93</td>
    <td style="white-space: nowrap; text-align: right">23.30 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;8.56%</td>
    <td style="white-space: nowrap; text-align: right">22.67 ms</td>
    <td style="white-space: nowrap; text-align: right">30.77 ms</td>
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
    <td style="white-space: nowrap;text-align: right">143.57</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">52.52</td>
    <td style="white-space: nowrap; text-align: right">2.73x</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">42.93</td>
    <td style="white-space: nowrap; text-align: right">3.34x</td>
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
    <td style="white-space: nowrap">2.92 MB</td>
    <td>&nbsp;</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap">18.78 MB</td>
    <td>6.43x</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap">19.46 MB</td>
    <td>6.66x</td>
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
    <td style="white-space: nowrap; text-align: right">85.66</td>
    <td style="white-space: nowrap; text-align: right">11.67 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;9.17%</td>
    <td style="white-space: nowrap; text-align: right">11.32 ms</td>
    <td style="white-space: nowrap; text-align: right">15.35 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">45.43</td>
    <td style="white-space: nowrap; text-align: right">22.01 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;14.84%</td>
    <td style="white-space: nowrap; text-align: right">21.75 ms</td>
    <td style="white-space: nowrap; text-align: right">31.04 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">33.18</td>
    <td style="white-space: nowrap; text-align: right">30.14 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;13.58%</td>
    <td style="white-space: nowrap; text-align: right">30.35 ms</td>
    <td style="white-space: nowrap; text-align: right">38.95 ms</td>
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
    <td style="white-space: nowrap;text-align: right">85.66</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap; text-align: right">45.43</td>
    <td style="white-space: nowrap; text-align: right">1.89x</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap; text-align: right">33.18</td>
    <td style="white-space: nowrap; text-align: right">2.58x</td>
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
    <td style="white-space: nowrap">3.88 MB</td>
    <td>&nbsp;</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">erlsom</td>
    <td style="white-space: nowrap">19.43 MB</td>
    <td>5.01x</td>
  </tr>
    <tr>
    <td style="white-space: nowrap">xmerl</td>
    <td style="white-space: nowrap">21.78 MB</td>
    <td>5.61x</td>
  </tr>
</table>