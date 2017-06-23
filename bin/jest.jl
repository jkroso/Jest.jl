#!/usr/bin/env julia
@require "github.com/jkroso/Emitter.jl" on emit
@require "github.com/jkroso/SimpleCLI.jl" @CLI
@require ".." => Jest

"""
Run the tests contained in <files> reporting the results with <reporter>.
You don't need to `@require` Jest in your test files since it will be injected
for you.
"""
@CLI (files::String...; reporter::String="dot")

# mixin event handlers
on(Jest.reporter, Kip.require("../reporters/$reporter").reporter)

fails = 0

on(Jest.reporter, "after assertion") do result
  global fails += !result.pass
end

const env = Dict(Symbol("testset") => getfield(Jest, Symbol("testset")),
                 Symbol("@test") => getfield(Jest, Symbol("@test")),
                 Symbol("@catch") => getfield(Jest, Symbol("@catch")))

try
  emit(Jest.reporter, "before all")

  for file in files
    Kip.require(joinpath(pwd(), file); env...)
  end

  emit(Jest.reporter, "after all")
catch e
  emit(Jest.reporter, "error", e)
  rethrow(e)
end

# exit with correct error code
exit(fails)
