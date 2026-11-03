using LinearAlgebra

using BoundaryIntegralPDE
using BoundaryIntegralPDE: matrix

for op in ops
    @printf("%d\t%s\t\t%.3e\t%s\n",
        op|>BoundaryIntegralPDE.matrix|>m->size(m, 2),
        op|>correction |> c -> try
            return c.order
        catch e
            return nothing
        end,
        op|>o -> begin
            m=BoundaryIntegralPDE.matrix(o);
            if (o isa DoubleLayer || o isa AdjointDoubleLayer)
                m = m-0.5I
            end
            m
        end |> cond,
        op|>typeof|>nameof)

end
