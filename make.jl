using Documenter
import NodeJS_16_jll
import LoggingExtras, LokiLogger, ProgressLogging, TerminalLoggers,
       SyslogLogging, LogRoller, LogCompose, Logging, Logging2, LoggingFormats,
       MiniLoggers

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

# Hack to deploy preview builds from package auto-update
# This is necessary since when using the create-pull-request action, the PR is opened
# by the github-actions user authenticating with the default GITHUB_TOKEN, which also
# means that regular CI will not be triggered. This is circumvented by using a SSH key
# with the actions/checkout action when cloning, which means that the resulting commit
# is pushed with the same SSH key triggering a "push" event build. However, Documenter
# only builds previews for the "pull_request" event type, so we need to pretend to be
# a "pull_request" event type by temporarily setting some environment variables.
env = Dict{String,String}()
if get(ENV, "GITHUB_EVENT_NAME", "") == "push" &&
   get(ENV, "GITHUB_REF", "") == "refs/heads/create-pull-request/package-update"
    env["GITHUB_EVENT_NAME"] = "pull_request"
    env["GITHUB_REF"] = "refs/pull/1234/merge"
end

withenv(env...) do
    deploydocs(
        versions = nothing,
        push_preview = true,
        repo = "github.com/JuliaLogging/julialogging.github.io.git",
    )
end
