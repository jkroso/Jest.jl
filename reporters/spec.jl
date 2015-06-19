const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const RESET = "\x1b[33m"
level = 0

render(msg::String) = println(" " ^ (level * 2 + 1), msg)

const reporter = {
  "before all" => function()
    println(RESET)
  end,
  "before test" => function(title)
    render("$RESET$(title[end])")
    global level += 1
  end,
  "after test" => function(test)
    global level -= 1
    level == 0 && println()
  end,
  "after assertion" => function(result)
    if result.pass
      render("$(GREEN)✓$RESET $(result.title[end])")
    else
      render("$(RED)✗$RESET $(result.title[end])")
    end
  end
}
