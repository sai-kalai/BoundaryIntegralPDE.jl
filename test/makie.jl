
using Test

using Makie

using BoundaryIntegralPDE
using BoundaryIntegralPDE.DevTools


@testset "makie recipes" begin


    n = 200
    t = (0:(n-1)) * 2pi / n
    b = DiscreteClosedCurve(t, starfish)
    x_test = Fixtures.test_locations()

    laplace = Laplace()

    bvp = BoundaryValueProblem(laplace, Dirichlet(sin.(t)), Interior(), b)

    biealg = DirectBIEAlgorithm(correction=Zeta(32))

    bvpalg = DirectBVPAlgorithm()

    sol = solve(bvp, bvpalg, biealg; target=x_test)

    @testset "tricontourf" begin

        fig, ax, pl = Makie.tricontourf(sol)

        @test pl isa Tricontourf
    end
    @testset "mesh" begin
        fig, ax, pl = Makie.mesh(sol)
        @test pl isa Mesh
        fig |> display
    end


end
