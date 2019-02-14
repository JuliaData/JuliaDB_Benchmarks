#-----------------------------------------------------------------------# Setup
include("utils.jl")

file = "hflights.csv"
url = "https://raw.githubusercontent.com/piever/JuliaDBTutorial/master/$file"
register(DataDep("flights", "flights data (18 MiB) for JuliaDB benchmarks", url))
path = joinpath(datadep"flights", file)

t = loadtable(path)

#-----------------------------------------------------------------------# benchmarks
b = BenchmarkGroup()
b["Missing"] = BenchmarkGroup()
b["DataValue"] = BenchmarkGroup()

d = OrderedDict()

#-----------------------------------------------------------------------# load tables
t = loadtable(path)
t2 = convertmissing(t, DataValue)

#-----------------------------------------------------------------------# convertmissing
d["convertmissing"] = "convert missing values to the other representation"
b["Missing"]["convertmissing"] = @benchmarkable convertmissing($t, DataValue)
b["DataValue"]["convertmissing"] = @benchmarkable convertmissing($t2, Missing)

#-----------------------------------------------------------------------# dropmissing
d["dropmissing"] = "drop rows that contain missing values"
b["Missing"]["dropmissing"] = @benchmarkable dropmissing($t)
b["DataValue"]["dropmissing"] = @benchmarkable dropmissing($t2)

#-----------------------------------------------------------------------# filter
d["filter"] = "filter on columns that contain missing values"
b["Missing"]["filter"] = @benchmarkable filter(i -> (i.Month == 1) && (i.DayofMonth == 1), $t)
b["DataValue"]["filter"] = @benchmarkable filter(i -> (i.Month == 1) && (i.DayofMonth == 1), $t2)

#-----------------------------------------------------------------------# select
b["Missing"]["select"] = @benchmarkable select($t, (:DepTime, :ArrTime, :FlightNum))
b["DataValue"]["select"] = @benchmarkable select($t2, (:DepTime, :ArrTime, :FlightNum))

b["Missing"]["select regex"] = @benchmarkable select($t, All(Between(:Year, :DayofMonth), r"Taxi|Delay"))
b["DataValue"]["select regex"] = @benchmarkable select($t2, All(Between(:Year, :DayofMonth), r"Taxi|Delay"))

b["Missing"]["sort"] = @benchmarkable sort($t, :DepDelay, select = (:UniqueCarrier, :DepDelay))
b["DataValue"]["sort"] = @benchmarkable sort($t, :DepDelay, select = (:UniqueCarrier, :DepDelay))

#-----------------------------------------------------------------------# map
b["Missing"]["map"] = @benchmarkable map(i -> i.DepDelay * 2, $t)
b["DataValue"]["map"] = @benchmarkable map(i -> i.DepDelay * 2, $t2)

f = i -> (DepDelay2 = 2 * i.DepDelay, AirTime2 = 2 * i.AirTime)
b["Missing"]["map namedtuple"] = @benchmarkable map(f, $t)
b["DataValue"]["map namedtuple"] = @benchmarkable map(f, $t2)

#-----------------------------------------------------------------------# groupby
b["Missing"]["groupby"] = @benchmarkable groupby(mean ∘ skipmissing, $t, :Dest, select = :ArrDelay)
b["DataValue"]["groupby"] = @benchmarkable groupby(mean ∘ dropna, $t2, :Dest, select = :ArrDelay)

#-----------------------------------------------------------------------# groupreduce
d["groupreduce"] = "calculate FTSeries(Mean()), filtering out missing values"
o1 = FTSeries(Mean(); filter = !ismissing)
o2 = FTSeries(DataValue, Mean(); filter = !isna, transform=get)
b["Missing"]["groupreduce"] = @benchmarkable groupreduce($(copy(o1)), $t, :Dest, select = :ArrDelay)
b["DataValue"]["groupreduce"] = @benchmarkable groupreduce($(copy(o2)), $t2, :Dest, select = :ArrDelay)


tune!(b, verbose=true)
results = run(b, verbose=true)

table_results(results, d)