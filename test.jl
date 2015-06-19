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
