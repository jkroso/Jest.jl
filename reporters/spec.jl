const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const RESET = "\x1b[33m"
level = 0
last_type = :none

render(msg::AbstractString) = println(" " ^ (level * 2 + 1), msg)

const reporter = Dict(
  "before all" => function()
    println(RESET)
  end,
  "after all" => function()
    last_type == :assertion && println()
  end,
  "before test" => function(title)
    level == 0 && last_type == :assertion && println()
    render("$RESET$(title[end])")
    global level += 1
  end,
  "after test" => function(test)
    global level -= 1
    global last_type = :test
    level == 0 && println()
  end,
  "after assertion" => function(result)
    global last_type = :assertion
    if result.pass
      render("$(GREEN)✓$RESET $(result.title[end])")
    else
      render("$(RED)✗$RESET $(result.title[end])")
    end
  end
)
