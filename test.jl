pass() = true
fail() = false

test(pass, "top level")

suite("suites should group") do
  test(pass, "test 1")
  suite("and should themselves be nestable") do
    test(pass, "test 2")
    test(pass, "test 3")
  end
  test(pass, "test 4")
end

suite("failiures") do
  test(fail, "test 1")
  test(fail, "test 2")
end

suite("macros") do
  @test 1 == 1
  @test 1 == 2
  @test_throws Exception error("boom")
  @test_throws Exception "not throwing"
end
