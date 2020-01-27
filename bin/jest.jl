#!/usr/bin/env julia --color=yes
@require "github.com/jkroso/Emitter.jl" on emit
@require "github.com/jkroso/SimpleCLI.jl" @CLI
@require ".." => Jest assertion testset

"""
Run the tests contained in <files> reporting the results with <writer>
"""
@CLI (files::String...; writer::String="dot",
                        reader::String="inject")

# mixin event handlers
on(Jest.reporter, Kip.require("../reporters/$writer").reporter)

fails = 0

on(Jest.reporter, "after assertion") do result
  global fails += !result.pass
end

const env = Dict(Symbol("testset") => getfield(Jest, Symbol("testset")),
                 Symbol("@test") => getfield(Jest, Symbol("@test")),
                 Symbol("@catch") => getfield(Jest, Symbol("@catch")))

read_testfile(file, ::Val{:basic}) = Kip.require(file)
read_testfile(file, ::Val{:inject}) = Kip.require(file; env...)
read_testfile(file, ::Val{:comments}) = begin
  m = Kip.require(file)
  test_comment = r"[ \t]*# (.+)"
  tests = []
  for (i, line) ∈ enumerate(eachline(file))
    occursin(test_comment, line) || continue
    str = match(test_comment, line)[1]
    code = try Meta.parse(str) catch; continue end
    push!(tests, :($(Jest.assertion)($str) do
      $(Expr(:line, i, Symbol(file)))
      $(code)
    end))
  end
  isempty(tests) && return
  Core.eval(m, :($(Jest.testset)(()->begin $(tests...) end, $(relpath(file)))))
end

try
  emit(Jest.reporter, "before all")

  for file in files
    path = realpath(joinpath(pwd(), file))
    read_testfile(path, Val(Symbol(reader)))
  end

  emit(Jest.reporter, "after all")
catch e
  emit(Jest.reporter, "error", e)
  rethrow(e)
end

# exit with correct error code
exit(fails)
