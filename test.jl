##
# Normally the tests would be embedded with the code it tests
# but in this case they need to be seperate due to the way Requirer
# caches modules
#
test("suites should group") do
	@assert 1 == 1
	test("and should themselves be nestable") do
		@assert 2 == 2
	end
	@assert 3 == 3
end

test("failures") do
	@assert false
end
