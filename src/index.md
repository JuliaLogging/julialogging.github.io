# JuliaLogging

This is the landing page of the [JuliaLogging GitHub organization](https://github.com/JuliaLogging/).
JuliaLogging is an umbrella organization for logging-related packages and repositories
in the [Julia programming language](https://julialang.org/) ecosystem.

Here's a summary of libraries which integrate with the standard logging
frontend macros `@debug`, `@info`, `@warn`, `@error` from `Base` and with the
abstractions from the
[`Logging`](https://docs.julialang.org/en/v1/stdlib/Logging) standard library.

### Frontend

* [`ProgressLogging.jl`](https://github.com/JuliaLogging/ProgressLogging.jl)
  provides some convenient frontend macros including `@progress` which makes it
  easy to emit log records tracking the progress of looping constructs.

### Log Event routing and transformation

* [`LoggingExtras.jl`](https://github.com/JuliaLogging/LoggingExtras.jl) provides
  generic log transformation, filtering and routing functionality. You can use
  this to mutate messages as they go through the chain, duplicate a stream of
  log records into multiple streams, discard messages based on a predicate, etc.
* [`Logging2.jl`](https://github.com/JuliaLogging/Logging2.jl) provides
  utilities to redirect

### Sinks

* The [`Logging`](https://docs.julialang.org/en/v1/stdlib/Logging) stdlib
  provides a default logger backend `ConsoleLogger` for basic filtering and
  pretty printing of log records in the terminal.
* [`TerminalLoggers.jl`](https://github.com/JuliaLogging/TerminalLoggers.jl) is a
  library for advanced terminal-based pretty printing of log records, including
  fancy progress bars and markdown formatting.
* [`TensorBoardLogger.jl`](https://github.com/PhilipVinc/TensorBoardLogger.jl)
  can log structured numeric data to
  [TensorBoard](https://www.tensorflow.org/tensorboard) as a backend.
* [`LogRoller.jl`](https://github.com/JuliaLogging/LogRoller.jl) has a backend for
  rotating log files once they hit a size limit.
* [`Syslogging.jl`](https://github.com/JuliaLogging/SyslogLogging.jl) provides a
  backend to direct logs to syslog.
* [`LoggingExtras.jl`](https://github.com/JuliaLogging/LoggingExtras.jl) provides a
  simple `FileLogger` sink.
* [LokiLogger](https://github.com/JuliaLogging/LokiLogger.jl) is a log message
  sink for [Grafana Loki](https://grafana.com/oss/loki/)

### Configuration

* [`LogCompose.jl`](https://github.com/JuliaLogging/LogCompose.jl) provides
  declarative logger configuration and an associated `.toml` file format.

