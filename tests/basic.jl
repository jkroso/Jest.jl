#! jest tests/basic.jl -r basic
@require ".." testset @test @catch

a = 1

testset("suites should group") do
  @test a == 1
  testset("and should themselves be nestable") do
    @test 2 == 2
  end
  @test 3 == 3
  @test isa(@catch(error("boom")), ErrorException)
end

@test a == 1

testset("failures") do
  @test true
  testset("can come from nested tests") do
    @test true
    @test false
  end
end

@test a == 1
