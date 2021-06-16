# OilData
Driver repository for OilData.jl

## Set up
```julia
pkg> add "https://ykyang@github.com/ykyang/OilData.jl.git"#main
pkg> develop --local OilData
```

Restore
```julia
pkg> add "https://ykyang@github.com/ykyang/OilData.jl.git"#main
```
## Test
```julia
import Pkg
Pkg.test("OilData")
```

or 

```julia
include("runtests.jl")
```

or

```julia
include("dev/OilData/test/runtests.jl")
```

## Develop
Write code in `dev/OilData` and interact, test with `run_****.jl`.  Port
what is in `run_****.jl` to `dev/OilData/test/test_****.jl`.