# JuliaDB Benchmarks (updated 2019-02-14)

    Julia Version 1.1.0
    Commit 80516ca202 (2019-01-21 21:24 UTC)
    Platform Info:
    OS: macOS (x86_64-apple-darwin14.5.0)
    CPU: Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz
    WORD_SIZE: 64
    LIBM: libopenlibm
    LLVM: libLLVM-6.0.1 (ORCJIT, haswell)


## `taxi.jl`

### JuliaDB vs. Pandas

![](https://user-images.githubusercontent.com/8075494/52812765-45f51d80-3066-11e9-98a4-6dee24a08b6d.png)

    group      bench                 mintrial                   desc
    ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    "JuliaDB"  "groupby 1"           TrialEstimate(1.177 s)     "mean(fare_amount) groupby passenger_count"
    "JuliaDB"  "groupby 1 (reduce)"  TrialEstimate(88.093 ms)   "No Description"
    "JuliaDB"  "groupby 2"           TrialEstimate(1.523 s)     "mean(fare_amount) groupby (dayofweek, passenger_count)"
    "JuliaDB"  "groupby 2 (reduce)"  TrialEstimate(279.942 ms)  "No Description"
    "JuliaDB"  "groupby 3"           TrialEstimate(1.392 s)     "number of trips, groupby <udf:weekend_trip>, :passenger_count"
    "JuliaDB"  "groupby 3 (reduce)"  TrialEstimate(283.322 ms)  "No Description"
    "JuliaDB"  "load (date)"         TrialEstimate(15.782 s)    "load data, parse date field as date type"
    "JuliaDB"  "load (string)"       TrialEstimate(17.340 s)    "load data, parse date field as string type"
    "Pandas"   "groupby 1"           TrialEstimate(93.648 ms)   "mean(fare_amount) groupby passenger_count"
    "Pandas"   "groupby 2"           TrialEstimate(706.597 ms)  "mean(fare_amount) groupby (dayofweek, passenger_count)"
    "Pandas"   "groupby 3"           TrialEstimate(2.479 s)     "number of trips, groupby <udf:weekend_trip>, :passenger_count"
    "Pandas"   "load (date)"         TrialEstimate(27.219 s)    "load data, parse date field as date type"
    "Pandas"   "load (string)"       TrialEstimate(19.921 s)    "load data, parse date field as string type"

## simulated.jl

### Distributed vs. Non-distributed

![](https://user-images.githubusercontent.com/8075494/52812129-c6b31a00-3064-11e9-9299-a5f1966edcab.png)

    group      bench            mintrial                   desc
    ──────────────────────────────────────────────────────────────────────────────────────────────
    "Dist"     "filter"         TrialEstimate(22.816 ms)   "No Description"
    "Dist"     "groupreduce 1"  TrialEstimate(8.818 ms)    "groupreduce of 10 groups"
    "Dist"     "groupreduce 2"  TrialEstimate(9.924 ms)    "groupreduce of 100 groups"
    "Dist"     "groupreduce 3"  TrialEstimate(12.903 ms)   "groupreduce of 1000 groups"
    "Dist"     "groupreduce 4"  TrialEstimate(214.244 ms)  "groupreduce of 10^6 (possible) groups"
    "Dist"     "map"            TrialEstimate(1.884 ms)    "No Description"
    "Dist"     "reduce"         TrialEstimate(5.514 ms)    "No Description"
    "Dist"     "select col"     TrialEstimate(17.355 ms)   "No Description"
    "Dist"     "select table"   TrialEstimate(52.825 ms)   "No Description"
    "Nondist"  "filter"         TrialEstimate(47.010 ms)   "No Description"
    "Nondist"  "groupreduce 1"  TrialEstimate(3.893 ms)    "groupreduce of 10 groups"
    "Nondist"  "groupreduce 2"  TrialEstimate(8.439 ms)    "groupreduce of 100 groups"
    "Nondist"  "groupreduce 3"  TrialEstimate(16.916 ms)   "groupreduce of 1000 groups"
    "Nondist"  "groupreduce 4"  TrialEstimate(579.980 ms)  "groupreduce of 10^6 (possible) groups"
    "Nondist"  "map"            TrialEstimate(872.699 μs)  "No Description"
    "Nondist"  "reduce"         TrialEstimate(3.824 ms)    "No Description"
    "Nondist"  "select col"     TrialEstimate(2.024 ns)    "No Description"
    "Nondist"  "select table"   TrialEstimate(48.128 ms)   "No Description"


## `flights.jl`

### `Union{T,Missing}` vs. `DataValue`

![](https://user-images.githubusercontent.com/8075494/52811169-71760900-3062-11e9-9a6e-21f1270edfad.png)

    group        bench             mintrial                   desc
    ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    "DataValue"  "convertmissing"  TrialEstimate(109.247 ms)  "convert missing values to the other representation"
    "DataValue"  "dropmissing"     TrialEstimate(118.365 ms)  "drop rows that contain missing values"
    "DataValue"  "filter"          TrialEstimate(36.623 ms)   "filter on columns that contain missing values"
    "DataValue"  "groupby"         TrialEstimate(298.068 ms)  "No Description"
    "DataValue"  "groupreduce"     TrialEstimate(265.364 ms)  "calculate FTSeries(Mean()), filtering out missing values"
    "DataValue"  "map"             TrialEstimate(39.157 ms)   "No Description"
    "DataValue"  "map namedtuple"  TrialEstimate(49.669 ms)   "No Description"
    "DataValue"  "select"          TrialEstimate(487.430 μs)  "No Description"
    "DataValue"  "select regex"    TrialEstimate(1.378 ms)    "No Description"
    "DataValue"  "sort"            TrialEstimate(46.358 ms)   "No Description"
    "Missing"    "convertmissing"  TrialEstimate(106.124 ms)  "convert missing values to the other representation"
    "Missing"    "dropmissing"     TrialEstimate(162.258 ms)  "drop rows that contain missing values"
    "Missing"    "filter"          TrialEstimate(220.693 ms)  "filter on columns that contain missing values"
    "Missing"    "groupby"         TrialEstimate(287.725 ms)  "No Description"
    "Missing"    "groupreduce"     TrialEstimate(261.683 ms)  "calculate FTSeries(Mean()), filtering out missing values"
    "Missing"    "map"             TrialEstimate(231.224 ms)  "No Description"
    "Missing"    "map namedtuple"  TrialEstimate(366.356 ms)  "No Description"
    "Missing"    "select"          TrialEstimate(747.985 μs)  "No Description"
    "Missing"    "select regex"    TrialEstimate(1.782 ms)    "No Description"
    "Missing"    "sort"            TrialEstimate(45.676 ms)   "No Description"