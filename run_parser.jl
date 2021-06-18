# Prototype for test_parser.jl

using Revise
using TerminalPager
using Test
using OilData
using Dates
using ProgressMeter

# May need to run runtests.jl first to load required functions
# Test, learn, understand here then move to test_parser.jl

# function add_day(start::Dates.DateTime, durations::Vector)
#     ret = fill(start, size(durations))
#     #ret = add_day

#     return d
# end

function learn_add_day()

end

function learn_rsm()
    nt = run_read_rsm()
    df_body = nt.body
    df_meta = nt.meta
    
    colname = find_column_name(df_meta, "WOPR", "ADA-1762", "")
    @test "WOPR_3" == colname
    days = df_body[!,"TIME"]
    @test days isa Vector{Float64}
    wopr = df_body[!, colname]
    @test wopr isa Vector{Float64}

    # Create vector of datetime from start date and days
    path = joinpath(data_dir(), "test_start_date.PRT")
    start_datetime = find_prt_start_date(path)
    timevec = add_day.(start_datetime, days)
end

function learn_schedule()
    path = joinpath(data_dir(), "test_start_date.PRT")
    start_datetime = find_prt_start_date(path)
    @test DateTime(2020, 1, 18) == start_datetime

    path = joinpath(data_dir(), "test_schedule.ixf")
    end_datetime = find_schedule_end_date(path)
    @test DateTime(2021,2,4) == end_datetime

    #@show delta = end_datetime - start_datetime
    day_count = convert(Day, end_datetime - start_datetime)
    @test Day(383) == day_count
    @test 383 == day_count.value
    @test day_count.value isa Int64

    day_count = convert(Day, DateTime(2021,2,5) - DateTime(2021,2,4))
    @test 1 == day_count.value
end

"""

Keep only `====` sections

```
======================================================================================================================================+
SECTION  The simulation has reached 05-Apr-2020 78 d.  E 3708s = 1h01m48s | C [3691s,3741s] | M [1.4G,1.6G,15.0G] | P [2.2G,2.8G,23.5G]
======================================================================================================================================-
```
"""
function sanitize_prt()
    path = joinpath(data_dir(), "Pad-6A_15_35.PRT")
    open(path, "r") do in
        path = joinpath(data_dir(), "test_current_date.PRT")
        open(path, "w") do out
            for line in eachline(in)
                if !startswith(line, "=============")
                    continue
                end

                println(out, line)
                println(out, readline(in))
                println(out, readline(in))
                println(out)
                #println(out)
            end
        end
    end
end

function learn_progress_meter()
    path = joinpath(data_dir(), "test_start_date.PRT")
    start_datetime = find_prt_start_date(path)
    
    path = joinpath(data_dir(), "test_schedule.ixf")
    end_datetime = find_schedule_end_date(path)

    day_count = convert(Day, end_datetime - start_datetime)
    progress = Progress(day_count.value, dt=0.5, desc="Running...", color=:green)
    done = Threads.Atomic{Bool}(false)
    path = joinpath(data_dir(), "progress.prt")
    rm(path, force=true)

    writefile = function()
        in  = open(joinpath(data_dir(), "test_current_date.PRT"), "r")
        out = open(path, "w")
        try
            for line in eachline(in)
                sleep(1/1600) # 1600 lines
                for i in 1:100
                     # print gargage to force write to disk
                    println(out, "$i .....................................................................")
                end
                println(out, line)
                #flush(out)
            end
        finally
            close(in)
            close(out)
        end
        
        Threads.atomic_or!(done, true)
    end

    readfile = function()
        while !isfile(path)
            sleep(0.1)
        end

        pos = 0
        while !done[]
            open(path, "r") do io
                try
                    datetime = find_prt_current_date(io, pos)
                    pos = position(io)
                    days = convert(Day, datetime - start_datetime)
                    update!(progress, days.value)
                catch e
                    if e isa ErrorException
                        # ignore
                    end
                end
            end
            sleep(0.5)      
        end

        finish!(progress)
    end

    read_task = Threads.@spawn readfile()
    write_task = Threads.@spawn writefile()
    
    wait(write_task)
    wait(read_task)
end

function learn_read_write()
    done = Threads.Atomic{Bool}(false)

    path = joinpath(data_dir(), "progress.prt")
    rm(path, force=true)

    writefile = function()
        in  = open(joinpath(data_dir(), "test_current_date.PRT"), "r")
        out = open(path, "w")
        try
            for line in eachline(in)
                sleep(10/1600) # 1600 lines
                for i in 1:100
                     # print gargage to force write to disk
                    println(out, "$i .....................................................................")
                end
                println(out, line)
                #flush(out)
            end
        finally
            close(in)
            close(out)
        end
        
        Threads.atomic_or!(done, true)
    end

    readfile = function()
        while !isfile(path)
            sleep(0.1)
        end

        pos = 0
        while !done[]
            open(path, "r") do io
                skip(io, pos)

                for line in eachline(io)
                    if !startswith(line, "SECTION")
                        continue
                    end
                    if length(line) < 48
                        continue
                    end
                    println(line)
                end

                pos = position(io)
            end            
        end
    end

    read_task = Threads.@spawn readfile()
    write_task = Threads.@spawn writefile()
    
    wait(write_task)
    wait(read_task)
end

#nt = run_read_rsm()
learn_add_day()
learn_rsm()
learn_schedule()
#sanitize_prt()
#learn_read_write()
learn_progress_meter()

nothing