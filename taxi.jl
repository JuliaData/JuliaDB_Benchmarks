#-----------------------------------------------------------------------# Setup
include("utils.jl")

file = "yellow_tripdata_2018-01.csv"
url = "https://s3.amazonaws.com/nyc-tlc/trip+data/$file"
register(DataDep("taxi", "taxi data (736MB) for JuliaDB benchmarks", url))
path = joinpath(datadep"taxi", file)

@pyimport pandas as pd


#-----------------------------------------------------------------------# Benchmarks
b = BenchmarkGroup()    # benchmarks
b["JuliaDB"] = BenchmarkGroup()
b["Pandas"] = BenchmarkGroup()

d = OrderedDict()       # descriptions


#-----------------------------------------------------------------------# load (date)
d["load (date)"] = "load data, parse date field as date type"
b["JuliaDB"]["load (date)"] = @benchmarkable loadtable(path)
b["Pandas"]["load (date)"] = @benchmarkable pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])


#-----------------------------------------------------------------------# load (string)
d["load (string)"] = "load data, parse date field as string type"
b["JuliaDB"]["load (string)"] = @benchmarkable loadtable($path, colparsers=Dict(2=>String, 3=>String))
b["Pandas"]["load (string)"] = @benchmarkable pd.read_csv($path)


@info "Loading datasets for groupby benchmarks"
t = loadtable(path)
t2 = pd.read_csv(path, parse_dates=["tpep_pickup_datetime", "tpep_dropoff_datetime"])


#-----------------------------------------------------------------------# groupby 1
d["groupby 1"] = "mean(fare_amount) groupby passenger_count"
b["JuliaDB"]["groupby 1"] = @benchmarkable groupby(mean, $t, :passenger_count; select=:fare_amount)
b["JuliaDB"]["groupby 1 (reduce)"] = @benchmarkable groupreduce(Mean(), $t, :passenger_count; select=:fare_amount)
b["Pandas"]["groupby 1"] = @benchmarkable $t2[:groupby]("passenger_count")["fare_amount"][:mean]()


#-----------------------------------------------------------------------# groupby 2
d["groupby 2"] = "mean(fare_amount) groupby (dayofweek, passenger_count)"
b["JuliaDB"]["groupby 2"] = @benchmarkable begin
    groupby(mean, $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end
b["JuliaDB"]["groupby 2 (reduce)"] = @benchmarkable begin
    groupreduce(Mean(), $t, (:tpep_pickup_datetime=>dayofweek, :passenger_count); select=:fare_amount)
end
b["Pandas"]["groupby 2"] = @benchmarkable begin
    $t2[:groupby]([$t2["tpep_pickup_datetime"][:dt][:dayofweek],"passenger_count"])["fare_amount"][:count]()
end


#-----------------------------------------------------------------------# groupby 3
d["groupby 3"] = "number of trips, groupby <udf:weekend_trip>, :passenger_count"
b["JuliaDB"]["groupby 3"] = @benchmarkable begin 
    groupby(length, $t, (:tpep_pickup_datetime => x->Dates.dayofweek(x) in (6,7), :passenger_count),
        select=:fare_amount)
end
b["JuliaDB"]["groupby 3 (reduce)"] = @benchmarkable begin 
    groupreduce(Sum(), $t, (:tpep_pickup_datetime => x->Dates.dayofweek(x) in (6,7), :passenger_count),
        select=:fare_amount)
end
b["Pandas"]["groupby 3"] = @benchmarkable begin
    $t2[:groupby](
        [$t2["tpep_pickup_datetime"][:dt][:dayofweek][:map](py"lambda x: x in (5,6)"),
        "passenger_count"]
    )["fare_amount"][:count]()
end


tune!(b)
results = run(b, verbose=true)

table_results(results, d)