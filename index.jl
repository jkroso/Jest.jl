@require "emitter" Events emit

type Result
  title::Vector{String}
  time::FloatingPoint
  pass::Bool
end

type Test
  title::String
  results::Vector{Result}
end

const stack = Test[]
const reporter = Events()

##
# Run a grouping of tests/assertions
#
function test(body::Function, title::String)
  push!(stack, Test(title, Test[]))
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

##
# Run an assertion returning a `Result`
#
function assert(body::Function, title::String)
  full_title = vcat(map(t -> t.title, stack), title)
  emit(reporter, "before assertion", full_title)
  time = @elapsed ok = body()
  result = Result(full_title, time, ok)
  isempty(stack) || push!(stack[end].results, result)
  emit(reporter, "after assertion", result)
  result
end

macro assert(expr)
  :(assert(@thunk($(esc(expr))), $(repr(expr))))
end

macro assert_throws(expr)
  quote
    assert($(repr(expr))) do
      try
        $(esc(expr))
        false
      catch e
        true
      end
    end
  end
end

macro catch(expr)
  quote
    try
      $(esc(expr))
    catch e
      e
    end
  end
end

##
# Handle pretty printing for the REPL etc..
#
Base.writemime(io::IO, ::MIME"text/plain", r::Result) = begin
  write(io, "$(r.pass ? '✓' : '✗') $(int(r.time * 1000))ms")
end

Base.writemime(io::IO, ::MIME"text/html", r::Result) = begin
  css = "padding:1px 5px;font-size:14px;color:$(r.pass ? "rgb(0, 226, 0)" : "red");"
  text = "$(r.pass ? '✓' : '✗') $(int(r.time * 1000))ms"
  write(io, "<div style=\"$css\">$text</div>")
end

##
# Embedded test suite
#
test("suites should group") do
  @assert 1 == 1
  test("and should themselves be nestable") do
    @assert 2 == 2
  end
  @assert 3 == 3
  @assert isa(@catch(error("boom")), ErrorException)
  @assert_throws error("boom")
end

test("failures") do
  @assert true
  test("can come from nested tests") do
    @assert true
    @assert false
  end
end

@assert 1 == 1
@assert 1 == 1
@assert 1 == 1
