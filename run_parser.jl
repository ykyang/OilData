# Prototype for test_parser.jl

using Revise
using TerminalPager
using Test
using OilData

# Test, learn, understand here then move to test_parser.jl

function run_filter()
    nt = run_read_rsm()
    df_body = nt.body
    df_meta = nt.meta
    
    #df = filter(["1", "3", "4"] => (c1,c3,c4) -> c1 == "WOPR" && c3 == "ADA-1762" && isempty(c4), df_meta)
    #@test "WOPR_3" == df[1,1]
    # use df[1,1] for column name to get column from nt.body
    # @show df_body[!,df[1,1]][100:110]
    #@show df_body[!,"TIME"][1:10]
    
    return nt
end

#nt = run_read_rsm()
nt = run_filter()

nothing