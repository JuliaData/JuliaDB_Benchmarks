using OrderedCollections, StatsPlots, DataDeps, JuliaDB, BenchmarkTools, Statistics, 
    DataValues, OnlineStats, PyCall, Dates, Faker, Distributed, Random

function table_results(results, d)
    group = String[]
    bench = String[]
    mintrial = BenchmarkTools.TrialEstimate[]
    desc = String[]
    for ky in keys(results)
        for (k, v) in pairs(results[ky])
            push!(group, ky)
            push!(bench, k)
            push!(desc, get(d, k, "No Description"))
            push!(mintrial, minimum(v))
        end
    end
    t = table((group=group, bench=bench, mintrial=mintrial, desc=desc), pkey=(1,2))
end


#-----------------------------------------------------------------------# Plot
function plot_results(results, d, kw...)
    t = table_results(results, d)
    groupedbar(select(t, :bench), select(t, :mintrial => x -> x.time / 1e9);
        group=select(t, :group), xrotation=60, ylab = "time (s)", xlab="Benchmark", kw...)
end
