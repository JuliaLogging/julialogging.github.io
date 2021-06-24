using Documenter

# Build the docs
makedocs(
    sitename = "JuliaLogging",
    pages = [
        "Home" => "index.md",
    ],
    format = Documenter.HTML(
    ),
)

deploydocs(
    repo = "github.com/JuliaLogging/julialogging.github.io.git",
)
