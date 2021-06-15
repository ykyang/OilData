# Prototype for test_parser.jl

using Revise
using Test
using OilData

function data_dir()
    
    #@info "pwd(): $path"
    # if basename(path) == "OilData"
    #     path = joinpath(path, "test")
    # end

    path = joinpath(pwd(), "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    path = joinpath(pwd(), "test", "data")
    if isdir(path)
        return path # ".../.../../OilData/test/data"
    end

    return nothing
end

function run_read_rsm()
    path = joinpath(data_dir(), "test_read_rsm.RSM")

    nt = nothing
    open(path, "r") do io
        nt = read_rsm(io)
    end
    
    df_body = nt.body
    df_meta = nt.meta
    #       No. of columns == No. of rows
    @test size(df_body)[2] == size(df_meta)[1]

    return nt
end

function run_filter()
    nt = run_read_rsm()
    df_body = nt.body
    df_meta = nt.meta
    
    df = filter(["1", "3", "4"] => (c1,c3,c4) -> c1 == "WOPR" && c3 == "ADA-1762" && isempty(c4), df_meta)
    @test "WOPR_3" == df[1,1]
    # use df[1,1] for column name to get column from nt.body
    # @show df_body[!,df[1,1]][100:110]
    @show df_body[!,"TIME"][1:10]
end

nt = run_read_rsm()
run_filter()

nothing