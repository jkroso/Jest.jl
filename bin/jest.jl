#!/usr/bin/env julia
@require "github.com/docopt/DocOpt.jl" docopt
@require "github.com/jkroso/emitter.jl" on emit
@require ".." reporter run_tests

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
on(reporter, Kip.require("../reporters/$handlers").reporter)

fails = 0

on(reporter, "after assertion") do result
  global fails += !result.pass
end

emit(reporter, "before all")

try
  for file in args["<file>"]
    Kip.require(joinpath(pwd(), file))
  end

  run_tests()

  emit(reporter, "after all")
catch e
  emit(reporter, "error", e)
  rethrow(e)
end

# exit with correct error code
exit(fails)
