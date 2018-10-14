##### Beginning of file

testmodulea_filename::String = joinpath("TestModuleA", "TestModuleA.jl")
testmoduleb_filename::String  = joinpath(
        "TestModuleB", "directory1", "directory2", "directory3",
        "directory4", "directory5", "TestModuleB.jl",
        )
testmodulec_filename::String = joinpath(mktempdir(), "TestModuleC.jl")
rm(testmodulec_filename; force = true, recursive = true)
open(testmodulec_filename, "w") do io
    write(io, "module TestModuleC end")
end
include(testmodulea_filename)
include(testmoduleb_filename)
include(testmodulec_filename)

##### End of file
