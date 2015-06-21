##
# Normally the tests would be embedded with the code it tests
# but in this case they need to be seperate so they don't get
# run every time Jest is used
#
test("suites should group") do
  @test a == 1
  test("and should themselves be nestable") do
    @test 2 == 2
  end
  @test 3 == 3
  @test isa(@catch(error("boom")), ErrorException)
end

test("failures") do
  @test true
  test("can come from nested tests") do
    @test true
    @test false
  end
end

@test a == 1
a = 1
