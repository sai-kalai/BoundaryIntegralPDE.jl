using Revise
using BoundaryIntegralPDE
using Documenter

DocMeta.setdocmeta!(BoundaryIntegralPDE, :DocTestSetup, :(using BoundaryIntegralPDE); recursive=true)

makedocs(;
    modules=[BoundaryIntegralPDE],
    authors="Simón Cadavid",
    sitename="BoundaryIntegralPDE.jl",
    format=Documenter.HTML(;
        canonical="https://sai-kalai.github.io/BoundaryIntegralPDE.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/sai-kalai/BoundaryIntegralPDE.jl",
    devbranch="main",
)
