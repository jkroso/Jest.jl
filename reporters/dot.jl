const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const GRAY = "\x1b[33m"
const RESET = "\x1b[0m"
const results = {}

const reporter = {
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
    time = reduce((n,r) -> n + r.time, 0, results)
    println("$GRAY ($(int(time * 1000))ms)\n")

    for i in [1:length(fails)]
      title = join(fails[i].title, ' ')
      println("$GRAY   $i)$RED $title")
    end
    failures > 0 && println()

    print("$RESET")
  end,
  "after test" => function(result)
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
}
