@require "emitter" Events emit

type Result
	title::String
	time::FloatingPoint
	pass::Bool
end

const stack = String[]
const reporter = Events()

function suite(body::Function, title::String)
	push!(stack, title)
	emit(reporter, "before suite", title)
	body()
	emit(reporter, "after suite", title)
	pop!(stack)
end

function test(body::Function, title::String)
	emit(reporter, "before test", title)
	time = @elapsed ok = body()
	emit(reporter, "after test", Result(title, time, ok))
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
