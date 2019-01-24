#-----------------------------------------------------------------------# Setup
using DataDeps, JuliaDB, PyCall, OrderedCollections, BenchmarkTools, Statistics, Dates,
    OnlineStats

file = "yellow_tripdata_2018-01.csv"
url = "https://s3.amazonaws.com/nyc-tlc/trip+data/$file"
register(DataDep("taxi", "taxi data (736MB) for JuliaDB benchmarks", url))
path = joinpath(datadep"taxi", file)

@pyimport pandas as pd

#-----------------------------------------------------------------------# Load (Date)
@info "Benchmark 1: Loading data, parse date fields as Date"
b1 = BenchmarkGroup()
b1["JuliaDB"] = @benchmarkable loadtable(path)
b1["Pandas"] = @benchmarkable pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])
tune!(b1)
b1res = run(b1, verbose=true)


#-----------------------------------------------------------------------# Load (String)
@info "Benchmark 2: Loading data, parse date fields as String"
b2 =  BenchmarkGroup()
b2["JuliaDB"] = @benchmarkable loadtable($path, colparsers=Dict(2=>String, 3=>String))
b2["Pandas"] = @benchmarkable pd.read_csv($path)
tune!(b2)
b2res = run(b2, verbose=true)


#-----------------------------------------------------------------------# Groupby
# groupby 1: Average fare_amount grouped by passenger_count
# groupby 2: Average fare_amount grouped by passenger_count and day of week
@info "Benchmark 3: groupby/groupreduce operations"
b3 = BenchmarkGroup()

@info "Loading datasets"
t = loadtable(path)
t2 = pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])

b3["JuliaDB groupby 1"] = @benchmarkable groupby(mean, $t, :passenger_count; select=:fare_amount)
b3["JuliaDB groupreduce 1"] = @benchmarkable groupreduce(Mean(), $t, :passenger_count; select=:fare_amount)
b3["JuliaDB groupby 2"] = @benchmarkable begin
    groupby(mean, $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end
b3["JuliaDB groupreduce 2"] = @benchmarkable begin
    groupreduce(Mean(), $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end

b3["Pandas groupby 1"] = @benchmarkable $t2[:groupby]("passenger_count")["fare_amount"][:mean]()
b3["Pandas groupby 2"] = @benchmarkable begin
    $t2[:groupby]([$t2["tpep_pickup_datetime"][:dt][:dayofweek],"passenger_count"])["fare_amount"][:count]()
end

tune!(b3)
b3res = run(b3, verbose=true)
