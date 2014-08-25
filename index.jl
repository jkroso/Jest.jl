
@require "emitter" Events emit

export run, suite, test, @test, @test_throws

abstract Runnable

immutable Suite <: Runnable
	title::String
	children::Array{Runnable,1}
	Suite(title) = new(title, Runnable[])
end

immutable Test <: Runnable
	body::Function
	title::String
	meta::Dict{Any,Any}
end

immutable Result
	test::Test
	time::Float64
	pass::Bool
end

const stack = Suite[Suite("")]

suite(body::Function, title::String) = begin
	s = Suite(title)
	push!(stack[end].children, s)
	push!(stack, s)
	body()
	pop!(stack)
end

test(body::Function, title::String) = test(body, title, Dict())
test(body::Function, title::String, meta::Dict) = begin
	t = Test(body, title, meta)
	push!(stack[end].children, t)
	t
end

macro test(expr)
	:(test(() -> $(esc(expr)), $(repr(expr))))
end

macro test_throws(expr)
	:(test($(repr(expr))) do
		try
			$(esc(expr))
			false
		catch e
			true
		end
	end)
end

run() = run(Events())

run(reporter::Events) = begin
	emit(reporter, "before all")
	try
		results = run(stack[1], reporter)
		emit(reporter, "after all", results)
		results
	catch e
		emit(reporter, "error", e)
		rethrow(e)
	end
end

run(suite::Suite, reporter::Events) = begin
	emit(reporter, "before suite", suite)
	results = map(it -> run(it, reporter), suite.children)
	emit(reporter, "after suite", suite)
	reduce(vcat, Result[], results)
end

run(test::Test, reporter::Events) = begin
	emit(reporter, "before test", test)
	time = @elapsed ok = test.body()
	result = Result(test, time, ok)
	emit(reporter, "after test", result)
	result
end
