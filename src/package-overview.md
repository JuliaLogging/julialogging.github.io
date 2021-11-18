# Logging package overview

This section contains an overview of the many packages that are related to logging in Julia.
Most of the packages integrate with the standard logging frontend macros `@debug`, `@info`,
`@warn`, and `@error` from `Base` and with the abstractions provided by the
[Logging.jl](@ref) standard library.

!!! note
    If some logging-related package is missing from the list below don't hesitate to
    contribute by adding it!

## [Logging.jl](@id logging-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLang/julia/tree/master/stdlib/Logging)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://docs.julialang.org/en/v1/stdlib/Logging/)

The Logging stdlib provides much of the logging infrastructure which most of the other
logging packages build upon. Among other things, Logging provides
[`global_logger`](@ref Logging.global_logger) and [`with_logger`](@ref Logging.with_logger)
for setting the global/local logger, the `AbstractLogger` interface, and three loggers:
 - [`ConsoleLogger`](@ref Logging.ConsoleLogger): default logger in the Julia REPL
 - [`SimpleLogger`](@ref Logging.SimpleLogger): a basic version of
   [`ConsoleLogger`](@ref Logging.ConsoleLogger)
 - [`NullLogger`](@ref Logging.NullLogger): logger equivalent of
   [`/dev/null`](https://en.wikipedia.org/wiki/Null_device).

Functionality from Logging is used in most of the tutorials and how-to's in this
documentation.

See the [Logging API reference](@ref Logging.jl) for details.


## [LoggingExtras.jl](@id loggingextras-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/LoggingExtras.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/LoggingExtras.jl/blob/master/README.md)

The LoggingExtras package provides many essential extensions to the Logging stdlib. For
example loggers for message filtering:
[`MinLevelLogger`](@ref LoggingExtras.MinLevelLogger),
[`EarlyFilteredLogger`](@ref LoggingExtras.EarlyFilteredLogger), and
[`ActiveFilteredLogger`](@ref LoggingExtras.ActiveFilteredLogger);
a [`TransformerLogger`](@ref LoggingExtras.TransformerLogger) for arbitrary message
transformations; a [`TeeLogger`](@ref LoggingExtras.TeeLogger) for message routing; and
three different logger sinks: [`FileLogger`](@ref LoggingExtras.FileLogger) for logging
to files on disk, [`FormatLogger`](@ref LoggingExtras.FormatLogger) for customizing the
logging output formatting, and
[`DatetimeRotatingFileLogger`](@ref LoggingExtras.DatetimeRotatingFileLogger) for
logging to files on disk that rotates based on the date. Functionality from LoggingExtras
is used in most how-to guides so refer to those for examples.

See the [LoggingExtras API reference](@ref LoggingExtras.jl) for details.


## [LoggingFormats.jl](@id loggingformats-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/LoggingFormats.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/LoggingFormats.jl/blob/master/README.md)

The LoggingFormats package provide some predefined logging formats to be used with
`FormatLogger`, `DatetimeRotatingFileLogger` from the `LoggingExtras.jl` package:
 - [`LoggingFormats.JSON`](@ref LoggingFormats.JSON): output log messages serialized to JSON,
 - [`LoggingFormats.LogFmt`](@ref LoggingFormats.LogFmt): output log messages formatted as
   [logfmt](https://brandur.org/logfmt),
 - [`LoggingFormats.Truncated`](@ref LoggingFormats.Truncated): similar formatting as
   `ConsoleLogger`, but with long messages truncated.

See the [LoggingFormats API reference](@ref LoggingFormats.jl) for details.


## [TerminalLoggers.jl](@id terminalloggers-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/TerminalLoggers.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://julialogging.github.io/TerminalLoggers.jl/stable/)

The TerminalLoggers package provides the
[`TerminalLogger`](@ref TerminalLoggers.TerminalLogger) which is a more advanced
terminal-based pretty printing of log records. In particular it supports Markdown formatting
of log messages and progress bars (built on top of the [ProgressLogging](@ref progresslogging-overview) package).

See the [TerminalLoggers API reference](@ref TerminalLoggers.jl) for details.


## [ProgressLogging.jl](@id progresslogging-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/ProgressLogging.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://julialogging.github.io/ProgressLogging.jl/stable/)

The ProgressLogging package provides some convenient frontend macros including
`@progress` which makes it easy to emit log records tracking the progress of
looping constructs.

See the [ProgressLogging API reference](@ref ProgressLogging.jl) for details.


## [LogRoller.jl](@id logroller-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/LogRoller.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/LogRoller.jl/blob/master/README.md)

The LogRoller package provide functionality for rotating log files when they hit a certain size limit. In particular
the `IO` [`RollingFileWriter`](@ref LogRoller.RollingFileWriter) (which can be combined with other loggers) and also
the [`RollingLogger`](@ref LogRoller.RollingLogger).

See the [LogRoller API reference](@ref LogRoller.jl) for details.


## [SyslogLogging.jl](@id logroller-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/SyslogLogging.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/SyslogLogging.jl/blob/master/README.md)

The SyslogLogging package provides the [`SyslogLogger`](@ref SyslogLogging.SyslogLogger) which writes messages to [syslog](https://en.wikipedia.org/wiki/Syslog).

See the [SyslogLogging API reference](@ref SyslogLogging.jl) for details.


## [Logging2.jl](@id logging2-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/Logging2.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/Logging2.jl/blob/master/README.md)

The Logging2 package provides utilities for redirecting `stdout` and `stderr` output to the
logging system.

See the [Logging2 API reference](@ref Logging2.jl) for details.


## [TensorBoardLogger.jl](@id tensorboardlogger-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/PhilipVinc/TensorBoardLogger.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://philipvinc.github.io/TensorBoardLogger.jl/stable/)

The TensorBoardLogger package can log structured numeric data to
[TensorBoard](https://www.tensorflow.org/tensorboard) as a backend.


## [LokiLogger.jl](@id lokilogger-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/LokiLogger.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/LokiLogger.jl/blob/master/README.md)

The LokiLogger package provides the [`LokiLogger.Logger`](@ref) logger which sends the log
messages over HTTP to a [Grafana Loki](https://grafana.com/oss/loki/) server.

See the [LokiLogger API reference](@ref LokiLogger.jl) for details.


## [LogCompose.jl](@id logcompose-overview)

[![](https://img.shields.io/badge/-code%20repository-blue)](https://github.com/JuliaLogging/LogCompose.jl)
[![](https://img.shields.io/badge/-external%20docs-blue)](https://github.com/JuliaLogging/LogCompose.jl/blob/master/README.md)

The LogCompose package provides declarative logger configuration and an associated `.toml`
file format.

See the [LogCompose API reference](@ref LogCompose.jl) for details.
