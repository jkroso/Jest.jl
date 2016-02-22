@require "github.com/jkroso/Emitter.jl@579aab0" Events emit

type Result
  title::Vector{AbstractString}
  time::AbstractFloat
  pass::Bool
end

type Suite
  title::AbstractString
  results::Vector{Result}
end

const stack = Suite[]
const reporter = Events()

const deferred_tests = Task[]
global ready = false

function run_tests()
  global ready = true
  map(consume, deferred_tests)
  empty!(deferred_tests)
end

"""
Run a suite of tests and sub-suites
"""
function test(body::Function, title::AbstractString)
  # Hack to prevent running tests in 3rd party modules
  @dirname() == pwd() || current_module() == Main || return
  # Hack to enable running files with embedded tests
  # Tests need to wait for the code they test to be defined
  ready || return push!(deferred_tests, @task test(body, title))

  push!(stack, Suite(title, Result[]))
  full_title = map(t -> t.title, stack)
  emit(reporter, "before test", full_title)
  time = @elapsed(body())
  pass = all(r -> r.pass, stack[end].results)
  result = Result(full_title, time, pass)
  length(stack) > 1 && push!(stack[end-1].results, result)
  emit(reporter, "after test", result)
  pop!(stack)
  result
end

"""
Run an assertion returning a `Result`
"""
function assertion(body::Function, title::AbstractString)
  @dirname() == pwd() || current_module() == Main || return
  ready || return push!(deferred_tests, @task assertion(body, title))

  full_title = vcat(map(t -> t.title, stack), title)
  emit(reporter, "before assertion", full_title)
  time = @elapsed ok = body()
  result = Result(full_title, time, ok)
  isempty(stack) || push!(stack[end].results, result)
  emit(reporter, "after assertion", result)
  result
end

"""
Define an assertion from an expression
"""
macro test(expr)
  :(assertion(function() $(esc(expr)) end, $(repr(expr))))
end

"""
Catch a value you expect to be thrown an return it insead so you
can run assertions on it. If the expression does not throw then
an error is raised
"""
macro catch(expr)
  quote
    (function()
      try $(esc(expr)) catch e return e end
      error("did not throw an error")
    end)()
  end
end

##
# Handle pretty printing for the REPL etc..
#
Base.writemime(io::IO, ::MIME"text/plain", r::Result) = begin
  write(io, "$(r.pass ? '✓' : '✗') $(round(Int, r.time * 1000))ms")
end

Base.writemime(io::IO, ::MIME"text/html", r::Result) = begin
  css = "padding:1px 5px;font-size:14px;color:$(r.pass ? "rgb(0, 226, 0)" : "red");"
  text = "$(r.pass ? '✓' : '✗') $(round(Int, r.time * 1000))ms"
  write(io, "<div style=\"$css\">$text</div>")
end

##
# With iJulia its common for the REPL to receive a large initial
# dump of code immediatly which may include some tests so we need
# to make sure those tests aren't run immediatly
#
if isinteractive()
  @schedule begin sleep(0.1); run_tests() end
end

export test, @test, @catch
