using Documenter
import NodeJS_16_jll
import LoggingExtras, LokiLogger, ProgressLogging, TerminalLoggers,
       SyslogLogging, LogRoller, LogCompose, Logging, Logging2, LoggingFormats,
       MiniLoggers

# "Backport" of JuliaLang/julia#40979
@eval Logging begin
    @doc """
    Alias for `LogLevel(-1000)`.
    """
    Debug
    @doc """
    Alias for `LogLevel(0)`.
    """
    Info
    @doc """
    Alias for `LogLevel(1000)`.
    """
    Warn
    @doc """
    Alias for `LogLevel(2000)`.
    """
    Error
end

# TODO: Upstream this
@eval LoggingFormats begin
    @doc """
        JSON

    Serialize log messages as JSON.
    """
    JSON

    @doc """
        LogFmt

    Format log messages as [logfmt](https://brandur.org/logfmt).
    """
    LogFmt

    @doc """
        Truncated

    Format log messages similar to `ConsoleLogger`, but truncate long messages.
    """
    Truncated
end

# Build the docs
makedocs(
    sitename = "JuliaLogging",
    pages = [
        "Home" => "index.md",
        "package-overview.md",
        "Tutorials" => [
            "tutorials/logging-basics.md",
            "tutorials/working-with-loggers.md",
            "tutorials/implement-a-new-logger.md",
        ],
        "How-to guides" => [
            "how-to/enable-debug.md",
            "how-to/log-to-file.md",
            "how-to/tee.md",
            "how-to/filter-messages.md",
            "how-to/rotate-log-files.md",
        ],
        "Reference" => [
            "reference/logcompose.md",
            "reference/logging.md",
            "reference/logging2.md",
            "reference/loggingextras.md",
            "reference/loggingformats.md",
            "reference/logroller.md",
            "reference/lokilogger.md",
            "reference/progresslogging.md",
            "reference/sysloglogging.md",
            "reference/terminalloggers.md",
            "reference/miniloggers.md",
        ],
        # "Background and discussion" => [
        # ],
    ],
    format = Documenter.HTML(
        assets = [
            "assets/julialogging.css",
            "assets/gruvbox-light-hard.css",
            "assets/gruvbox-dark-hard.css",
            "assets/favicon.ico",
        ],
        collapselevel = 1,
        ansicolor = true,
        prerender = get(ENV, "GITHUB_ACTIONS", nothing) == "true",
        node = NodeJS_16_jll.node(),
        highlightjs = joinpath(@__DIR__, "src", "assets", "julia.highlight.min.js"),
    ),
)

deploydocs(
    versions = nothing,
    push_preview = true,
    repo = "github.com/JuliaLogging/julialogging.github.io.git",
)
