#-----------------------------------------------------------------------# Setup
include("utils.jl")

nprocs() < 2 && addprocs()
@everywhere using JuliaDB, OnlineStats

#-----------------------------------------------------------------------# create dataset
n = 10^6

t = table((
    group = rand(1:10, n),
    subgroup = rand(1:100, n),
    subsubgroup = rand(1:1000, n),
    username = [randstring(10) for i in 1:n],
    state = [Faker.state() for i in 1:n],
    x = rand(n)

), pkey=(1,2,3))

dt = distribute(t, nworkers())


#-----------------------------------------------------------------------# Benchmarks
b = BenchmarkGroup()
b["Nondist"] = BenchmarkGroup()
b["Dist"] = BenchmarkGroup()

d = OrderedDict()   # descriptions

#-----------------------------------------------------------------------# select column
b["Nondist"]["select col"] = @benchmarkable select($t, :group)
b["Dist"]["select col"] = @benchmarkable select($dt, :group)

#-----------------------------------------------------------------------# select table
b["Nondist"]["select table"] = @benchmarkable select($t, Not(:group))
b["Dist"]["select table"] = @benchmarkable select($dt, Not(:group))

#-----------------------------------------------------------------------# filter
b["Nondist"]["filter"] = @benchmarkable filter(x -> x.group == 1, $t)
b["Dist"]["filter"] = @benchmarkable filter(x -> x.group == 1, $dt)

#-----------------------------------------------------------------------# map
b["Nondist"]["map"] = @benchmarkable map(x -> x + 1, $t; select=:group)
b["Dist"]["map"] = @benchmarkable map(x -> x + 1, $dt; select=:group)

#-----------------------------------------------------------------------# reduce
b["Nondist"]["reduce"] = @benchmarkable reduce(Mean(), $t; select=:x)
b["Dist"]["reduce"] = @benchmarkable reduce(Mean(), $dt; select=:x)

#-----------------------------------------------------------------------# groupreduce 1
d["groupreduce 1"] = "groupreduce of 10 groups"
b["Nondist"]["groupreduce 1"] = @benchmarkable groupreduce(Mean(), $t, :group; select=:x)
b["Dist"]["groupreduce 1"] = @benchmarkable groupreduce(Mean(), $dt, :group; select=:x)

#-----------------------------------------------------------------------# groupreduce 2
d["groupreduce 2"] = "groupreduce of 100 groups"
b["Nondist"]["groupreduce 2"] = @benchmarkable groupreduce(Mean(), $t, :subgroup; select=:x)
b["Dist"]["groupreduce 2"] = @benchmarkable groupreduce(Mean(), $dt, :subgroup; select=:x)

#-----------------------------------------------------------------------# groupreduce 3
d["groupreduce 3"] = "groupreduce of 1000 groups"
b["Nondist"]["groupreduce 3"] = @benchmarkable groupreduce(Mean(), $t, :subsubgroup; select=:x)
b["Dist"]["groupreduce 3"] = @benchmarkable groupreduce(Mean(), $dt, :subsubgroup; select=:x)

#-----------------------------------------------------------------------# groupreduce 4
d["groupreduce 4"] = "groupreduce of 10^6 (possible) groups"
b["Nondist"]["groupreduce 4"] = @benchmarkable groupreduce(Mean(), $t, (:group, :subgroup, :subsubgroup); select=:x)
b["Dist"]["groupreduce 4"] = @benchmarkable groupreduce(Mean(), $dt, (:group, :subgroup, :subsubgroup); select=:x)

tune!(b)
results = run(b, verbose=true)
table_results(results, d)