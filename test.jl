##
# Normally the tests would be embedded with the code it tests
# but in this case they need to be seperate so they don't get
# run every time Jest is used
#
test("suites should group") do
  @assert a == 1
  test("and should themselves be nestable") do
    @assert 2 == 2
  end
  @assert 3 == 3
  @assert isa(@catch(error("boom")), ErrorException)
end

test("failures") do
  @assert true
  test("can come from nested tests") do
    @assert true
    @assert false
  end
end

@assert a == 1
a = 1
