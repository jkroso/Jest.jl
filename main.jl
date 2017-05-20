@require "github.com/jkroso/Emitter.jl" Events emit
@require "github.com/JunoLab/Juno.jl" => Juno

struct Result
  title::Vector{AbstractString}
  time::AbstractFloat
  pass::Bool
end

struct Suite
  title::AbstractString
  results::Vector{Result}
end

const stack = Vector{Suite}()
const reporter = Events()

"""
Run a suite of tests and sub-suites
"""
function testset(body::Function, title::AbstractString)
  push!(stack, Suite(title, []))
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
  full_title = vcat(map(t -> t.title, stack), title)
  emit(reporter, "before assertion", full_title)
  time = @elapsed ok = body()::Bool
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
Base.show(io::IO, r::Result) = write(io, "$(r.pass ? '✓' : '✗') $(round(Int, r.time * 1000))ms")
Base.show(io::IO, ::MIME"text/html", r::Result) = begin
  css = "color:$(r.pass ? "rgb(0, 226, 0)" : "red");"
  text = "$(r.pass ? '✓' : '✗') $(round(Int, r.time * 1000))ms"
  write(io, "<div style=\"$css\">$text</div>")
end

##
# Hook into Juno's rendering system
#
Juno.render(::Juno.Inline, x::Result) = Juno.view(x)

export testset, @test, @catch
