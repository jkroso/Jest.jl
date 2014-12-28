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

function suite(body::Function, title::String)
	s = Suite(title)
	push!(stack[end].children, s)
	push!(stack, s)
	body()
	pop!(stack)
end

function test(body::Function, title::String, meta::Dict=Dict())
	t = Test(body, title, meta)
	push!(stack[end].children, t)
	t
end

macro test(expr)
	:(test(() -> $(esc(expr)), $(repr(expr))))
end

macro test_throws(T, expr)
	quote
		test($(repr(expr))) do
			try
				$(esc(expr))
				false
			catch e
				isa(e, $T)
			end
		end
	end
end

function run(reporter::Events)
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

function run(suite::Suite, reporter::Events)
	emit(reporter, "before suite", suite)
	results = map(it -> run(it, reporter), suite.children)
	emit(reporter, "after suite", suite)
	reduce(vcat, Result[], results)
end

function run(test::Test, reporter::Events)
	emit(reporter, "before test", test)
	time = @elapsed ok = test.body()
	result = Result(test, time, ok)
	emit(reporter, "after test", result)
	result
end

run(reporter=Dict()) = run(Events(reporter))
