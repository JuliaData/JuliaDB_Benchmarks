# JuliaDB Benchmarks


## `flights.jl`

Mainly a test of `Union{T,Missing}` vs. `DataValue`

```
benchmark                              time
────────────────────────────────────────────────────────
"convertmissing (DataValue->Missing)"  Trial(107.767 ms)
"convertmissing (Missing->DataValue)"  Trial(109.848 ms)
"dropmissing (DataValue)"              Trial(127.686 ms)
"dropmissing (Missing)"                Trial(157.528 ms)
"filter (DataValue)"                   Trial(37.666 ms)
"filter (Missing)"                     Trial(221.575 ms)
"groupby (DataValue)"                  Trial(294.180 ms)
"groupby (Missing)"                    Trial(301.786 ms)
"groupreduce (DataValue"               Trial(272.996 ms)
"groupreduce (Missing)"                Trial(264.378 ms)
"loadtable"                            Trial(555.216 ms)
"map (DataValue)"                      Trial(41.674 ms)
"map (Missing)"                        Trial(234.695 ms)
"map namedtuple (DataValue"            Trial(49.330 ms)
"map namedtuple (Missing)"             Trial(360.641 ms)
"select (DataValue)"                   Trial(481.273 μs)
"select (Missing)"                     Trial(662.995 μs)
"select regex (DataValue)"             Trial(1.374 ms)
"select regex (Missing)"               Trial(1.769 ms)
"sort (DataValue)"                     Trial(45.009 ms)
"sort (Missing)"                       Trial(48.218 ms)
```

## `taxi.jl`

Mainly a test of JuliaDB vs. Pandas

```
benchmark                  time
────────────────────────────────────────────
"groupby 1 (JuliaDB)"      Trial(1.144 s)
"groupby 1 (Pandas)"       Trial(94.420 ms)
"groupby 2 (JuliaDB)"      Trial(1.542 s)
"groupby 2 (Pandas)"       Trial(711.444 ms)
"groupreduce 1 (JuliaDB)"  Trial(91.313 ms)
"groupreduce 2 (JuliaDB)"  Trial(283.567 ms)
"load date (JuliaDB)"      Trial(15.648 s)
"load date (Pandas)"       Trial(28.115 s)
"load string (JuliaDB)"    Trial(17.732 s)
"load string (Pandas)"     Trial(20.740 s)
```