#-----------------------------------------------------------------------# Setup
using DataDeps, JuliaDB, PyCall, OrderedCollections, BenchmarkTools, Statistics, Dates,
    OnlineStats

file = "yellow_tripdata_2018-01.csv"
url = "https://s3.amazonaws.com/nyc-tlc/trip+data/$file"
register(DataDep("taxi", "taxi data (736MB) for JuliaDB benchmarks", url))
path = joinpath(datadep"taxi", file)

@pyimport pandas as pd

#-----------------------------------------------------------------------# Benchmarks
b = BenchmarkGroup()

b["load date (JuliaDB)"] = @benchmarkable loadtable(path)
b["load date (Pandas)"] = @benchmarkable pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])

b["load string (JuliaDB)"] = @benchmarkable loadtable($path, colparsers=Dict(2=>String, 3=>String))
b["load string (Pandas)"] = @benchmarkable pd.read_csv($path)

@info "Loading datasets for groupby benchmarks"
t = loadtable(path)
t2 = pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])

b["groupby 1 (JuliaDB)"] = @benchmarkable groupby(mean, $t, :passenger_count; select=:fare_amount)
b["groupreduce 1 (JuliaDB)"] = @benchmarkable groupreduce(Mean(), $t, :passenger_count; select=:fare_amount)
b["groupby 1 (Pandas)"] = @benchmarkable $t2[:groupby]("passenger_count")["fare_amount"][:mean]()


b["groupby 2 (JuliaDB)"] = @benchmarkable begin
    groupby(mean, $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end
b["groupreduce 2 (JuliaDB)"] = @benchmarkable begin
    groupreduce(Mean(), $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end
b["groupby 2 (Pandas)"] = @benchmarkable begin
    $t2[:groupby]([$t2["tpep_pickup_datetime"][:dt][:dayofweek],"passenger_count"])["fare_amount"][:count]()
end

tune!(b)

results = run(b, verbose=true)
