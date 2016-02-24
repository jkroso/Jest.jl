#!/usr/bin/env julia
@require "github.com/docopt/DocOpt.jl" docopt
@require "github.com/jkroso/emitter.jl" on emit
@require ".." => Jest

const usage = """

Usage:
  jest [--reporter=<name>] <file>...
  jest -h | --help
  jest -v | --version

Options:
  -h --help     Show this screen
  -v --version  Show version
  -r --reporter Select a custom reporter

"""

args = docopt(usage, version=v"0.0.0")

if args["--reporter"] == nothing
  args["--reporter"] = "dot"
end

handlers = args["--reporter"]

# mixin event handlers
on(Jest.reporter, Kip.require("../reporters/$handlers").reporter)

fails = 0

on(Jest.reporter, "after assertion") do result
  global fails += !result.pass
end

emit(Jest.reporter, "before all")

const env = Dict(symbol("test") => Jest.(symbol("test")),
                 symbol("@test") => Jest.(symbol("@test")),
                 symbol("@catch") => Jest.(symbol("@catch")))

try
  for file in args["<file>"]
    Kip.require(joinpath(pwd(), file); env...)
  end

  Jest.run_tests()

  emit(Jest.reporter, "after all")
catch e
  emit(Jest.reporter, "error", e)
  rethrow(e)
end

# exit with correct error code
exit(fails)
