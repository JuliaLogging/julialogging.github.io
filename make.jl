using Documenter
import LoggingExtras, LokiLogger, ProgressLogging, TerminalLoggers,
       SyslogLogging, LogRoller, LogCompose, Logging, Logging2

# Build the docs
makedocs(
    sitename = "JuliaLogging",
    pages = [
        "Home" => "index.md",
        "How-to guides" => [
            "how-to/enable-debug.md",
            "how-to/log-to-file.md",
        ],
        "Reference" => [
            "logging.md",
            "loggingextras.md",
            "terminalloggers.md",
            "progresslogging.md",
            "lokilogger.md",
            "logroller.md",
            "logcompose.md",
            "sysloglogging.md",
            "logging2.md",
        ],
    ],
    format = Documenter.HTML(
        assets = ["assets/julialogging.css"],
    ),
)

deploydocs(
    versions = nothing,
    push_preview = true,
    repo = "github.com/JuliaLogging/julialogging.github.io.git",
)
