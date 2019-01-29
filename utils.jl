using OrderedCollections

function result_table(results)
    result_dict = sort(Dict(results...))
    x = collect(keys(result_dict))
    y = collect(values(result_dict))
    table((benchmark=x, time = y))
end