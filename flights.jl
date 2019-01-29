#-----------------------------------------------------------------------# Setup
using DataDeps, JuliaDB, BenchmarkTools, Statistics, DataValues, OnlineStats

file = "hflights.csv"
url = "https://raw.githubusercontent.com/piever/JuliaDBTutorial/master/$file"
register(DataDep("flights", "flights data (18 MiB) for JuliaDB benchmarks", url))
path = joinpath(datadep"flights", file)

t = loadtable(path)

#-----------------------------------------------------------------------# benchmarks
b = BenchmarkGroup()

b["loadtable"] = @benchmarkable loadtable(path)

t = loadtable(path)
t2 = convertmissing(t, DataValue)

b["convertmissing (Missing->DataValue)"] = @benchmarkable convertmissing($t, DataValue)
b["convertmissing (DataValue->Missing)"] = @benchmarkable convertmissing($t2, Missing)

b["dropmissing (Missing)"] = @benchmarkable dropmissing($t)
b["dropmissing (DataValue)"] = @benchmarkable dropmissing($t2)

b["filter (Missing)"] = @benchmarkable filter(i -> (i.Month == 1) && (i.DayofMonth == 1), $t)
b["filter (DataValue)"] = @benchmarkable filter(i -> (i.Month == 1) && (i.DayofMonth == 1), $t2)

b["select (Missing)"] = @benchmarkable select($t, (:DepTime, :ArrTime, :FlightNum))
b["select (DataValue)"] = @benchmarkable select($t2, (:DepTime, :ArrTime, :FlightNum))

b["select regex (Missing)"] = @benchmarkable select($t, All(Between(:Year, :DayofMonth), r"Taxi|Delay"))
b["select regex (DataValue)"] = @benchmarkable select($t2, All(Between(:Year, :DayofMonth), r"Taxi|Delay"))

b["sort (Missing)"] = @benchmarkable sort($t, :DepDelay, select = (:UniqueCarrier, :DepDelay))
b["sort (DataValue)"] = @benchmarkable sort($t, :DepDelay, select = (:UniqueCarrier, :DepDelay))

b["map (Missing)"] = @benchmarkable map(i -> i.DepDelay * 2, $t)
b["map (DataValue)"] = @benchmarkable map(i -> i.DepDelay * 2, $t2)

f = i -> (DepDelay2 = 2 * i.DepDelay, AirTime2 = 2 * i.AirTime)
b["map namedtuple (Missing)"] = @benchmarkable map(f, $t)
b["map namedtuple (DataValue"] = @benchmarkable map(f, $t2)

b["groupby (Missing)"] = @benchmarkable groupby(mean ∘ skipmissing, $t, :Dest, select = :ArrDelay)
b["groupby (DataValue)"] = @benchmarkable groupby(mean ∘ dropna, $t2, :Dest, select = :ArrDelay)

o1 = FTSeries(Mean(); filter = !ismissing)
o2 = FTSeries(DataValue, Mean(); filter = !isna, transform=get)
b["groupreduce (Missing)"] = @benchmarkable groupreduce($(copy(o1)), $t, :Dest, select = :ArrDelay)
b["groupreduce (DataValue"] = @benchmarkable groupreduce($(copy(o2)), $t2, :Dest, select = :ArrDelay)

tune!(b, verbose=true)

results = run(b, verbose=true)