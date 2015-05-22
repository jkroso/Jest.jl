const RED   = "\x1b[31m"
const GREEN = "\x1b[32m"
const RESET = "\x1b[33m"
level = 0

render(msg::String) = println(" " ^ (level * 2), msg)

const reporter = {
  "before suite" => function(suite)
    render("$RESET$(suite.title)")
    global level += 1
  end,
  "after suite" => function(suite)
    global level -= 1
    level == 0 && println()
  end,
  "after test" => function(result)
    if result.pass
      render("$(GREEN)✔$RESET $(result.test.title)")
    else
      render("$(RED)✖$RESET $(result.test.title)")
    end
  end
}
