const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const RESET = "\x1b[0m"
const results = []

const reporter = Dict(
  "before all" => function()
    print("\n   ")
  end,
  "after all" => function()
    if length(results) == 0
      println("No tests declared")
      println()
      return
    end

    fails = filter(t -> !t.pass, results)
    failures = length(fails)
    passes = length(results) - failures

    print("\n\n  ")
    passes > 0 && print("$GREEN $passes passing")
    failures > 0 && print("$RED $failures failing")
    time = reduce((n,r) -> n + r.time, results, init=0)
    println("$RESET ($(round(Int, time * 1000))ms)\n")

    for i in eachindex(fails)
      title = join(fails[i].title, ' ')
      println("$RESET   $i)$RED $title")
    end
    failures > 0 && println()

    print("$RESET")
  end,
  "after assertion" => function(result)
    push!(results, result)
    if result.pass
      print("$(GREEN).$(RESET)")
    else
      print("$(RED).$(RESET)")
    end
  end,
  "error" => function(e)
    println(RESET)
    println()
  end
)
