@require "emitter" Events

export reporter

const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const GRAY = "\x1b[33m"
const RESET = "\x1b[0m"
const fails = String[]
count = 0

const reporter = Events({
	"before all" => function()
		print("\n   ")
	end,
	"after all" => function(results)
		if count == 0
			println("No tests declared")
			println()
			return
		end

		failures = length(fails)
		passes = count - failures

		print("\n\n  ")
		passes > 0 && print("$GREEN $passes passing")
		failures > 0 && print("$RED $failures failing")
		time = reduce((n,r) -> n + r.time, 0, results)
		println("$GRAY ($(int(time * 1000))ms)\n")

		for i in [1:length(fails)]
			println("$GRAY   $i)$RED $(fails[i])")
		end
		failures > 0 && println()

		print("$RESET")
	end,
	"after test" => function(result)
		global count += 1
		if result.pass
			print("$(GREEN).")
		else
			print("$(RED).")
			push!(fails, result.test.title)
		end
	end,
	"error" => function(e)
		println(RESET)
		println()
	end
})
