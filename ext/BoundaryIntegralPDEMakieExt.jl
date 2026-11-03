
module BoundaryIntegralEquationsMakieExt

using DelaunayTriangulation
using Makie

using BoundaryIntegralEquations
import BoundaryIntegralEquations: boundarycurve, boundarycurve!

# non inplace version to allocate fig and ax
function BoundaryIntegralEquations.visualize(
    args...;
    kwargs...,
)
    fig = Figure()
    ax = Axis(fig[1, 1]; aspect=DataAspect())
    return fig, ax, visualize!(ax, args..., kwargs...)
end

function BoundaryIntegralEquations.visualize!(
    ax::Axis,
    b,
    # TODO: these should be kwargs
    arrows::Bool=false,
    parameter::Bool=false,
    ;
    line_kwargs=(;),
    arr_kwargs=(;),
)

    l = lines!(
        ax,
        polygon(b),
        ;
        label="Γ",
        colormap=Makie.to_colormap(:viridis),
        colorrange=(1, size(b, 2) + 1),
        color=parameter ? (1:(size(b, 2)+1)) : :black,
        line_kwargs...,
    )

    if !arrows
        return l
    end
    n = arrows2d!(ax, eachrow(b.x)..., eachrow(b.n)...;
        color="red",
        lengthscale=0.1,
        # label=L"\hat{n}_y"
        arr_kwargs...,
    )
    t = arrows2d!(ax, eachrow(b.x)..., real.(b.cw), imag.(b.cw),
        color="blue",
        lengthscale=0.3,
        # label="Complex Weight"
        arr_kwargs...,
    )
    return l, n, t
end


@doc raw"""
    Makie.tricontourf!(ax::Axis, b::DiscreteClosedCurve, positions::AbstractMatrix, values::AbstractVector, boundary_values::AbstractVector, ;, kwargs...)

triangulated contour filled plot. Calculates triangulation including boundary
points
"""
function Makie.tricontourf!(
    ax::Axis,
    b::DiscreteClosedCurve,
    positions,
    values,
    boundary_values,
    ;
    kwargs...
)

    # extract from col-major ordering into vector of tuples
    points = [Tuple(p) for p in eachcol(positions)]
    # make polygon from vertices of boundary
    poly = polygon(b)

    boundary_nodes, points = convert_boundary_points_to_indices(
        [poly,],
        ;
        existing_points=points
    )

    tri = triangulate(points; boundary_nodes=boundary_nodes)

    z = [
        values
        boundary_values
    ]


    co = Makie.tricontourf!(ax, tri, z; kwargs...)

    # x, y = eachrow(positions)
    # Makie.scatter!(ax, x, y; color=:red, marker=:cross)

    return co
end

@doc raw"""
    Makie.contourf!(ax::Axis, b::DiscreteClosedCurve, xs::AbstractVector, ys::AbstractVector, values::AbstractVector)

Contour plot some scalar function in a domain enclosed by `b`

# Arguments
- `ax::Axis`: axis to modify
- `b::DiscreteClosedCurve`: boundary
- `xs::AbstractVector`: x values, of size (N, )
- `ys::AbstractVector`: y values, of size (M, )
- `values::AbstractVector`: function values, of size (N, M)
"""
function Makie.contourf!(
    ax::Axis,
    b::DiscreteClosedCurve,
    xs,
    ys,
    values,
    ;
    kwargs...
)

    co = Makie.contourf!(ax, xs, ys, values; kwargs...)
    return co
end



# recipes
@recipe BoundaryCurve begin
    color = :black
    linewidth = 1.5
    arrs = false
end

function Makie.plot!(
    bc::BoundaryCurve{<:Tuple{<:DiscreteClosedCurve}}
)

    input_nodes = [:converted_1]
    output_nodes = [:node_locs, :n_tips, :t_tips]

    map!(bc.attributes, input_nodes, output_nodes) do bdry

        return (
            Point2f[eachcol(bdry.x)...],
            Point2f[eachcol(bdry.n)...],
            Point2f[(real(w), imag(w)) for w in bdry.cw]
        )
    end

    # NOTE: lines slightly faster but less convenient
    poly!(
        bc,
        bc.node_locs,
        strokecolor=bc.color,
        color=:transparent,
        strokewidth=bc.linewidth,
    )

    if bc.arrs[]
        arrows2d!(
            bc,
            bc.node_locs,
            bc.n_tips,
            color=:blue,
            lengthscale=0.1,
        )

        arrows2d!(
            bc,
            bc.node_locs,
            bc.t_tips,
            color=:red,
        )
    end

    return bc
end

function Makie.convert_arguments(::Type{<:Tricontourf}, sol::BVPSolution)

    @info "convert arguments tricontourf"

    # extract from col-major ordering into vector of tuples
    points = [Tuple(p) for p in eachcol(sol.x)]
    # make polygon from vertices of boundary
    poly = polygon(sol.prob.boundary)

    boundary_nodes, points = convert_boundary_points_to_indices(
        [poly,],
        ;
        existing_points=points
    )

    tri = triangulate(points; boundary_nodes=boundary_nodes)

    z = [
        sol.u
        data(sol.prob.bc)
    ]

    return (tri, z)
    # co = Makie.tricontourf!(ax, tri, z; kwargs...)

end

function Makie.convert_arguments(::Type{<:Contourf}, sol::BVPSolution)
    # WARN: still broken, only use tricontourf for now
    @info "convert arguments contourf"

    xs, ys = unique.(eachrow(sol.x))

    return (xs, ys, reshape(sol.u, length(xs), length(ys)))

end


end
