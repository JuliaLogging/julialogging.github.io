# How to enable `@debug` messages

By default log messages with the debug level (e.g. from `@debug`) are not visible. This is
because the lowest log level accepted by the default `ConsoleLogger` is `Logging.Info` --
anything below that will be discarded.

The simplest way to enable all `@debug`-level messages is thus to create a new logger
that accept also these messages. Here is an example of that:

```@example enable-debug
using Logging

# New ConsoleLogger that prints to stderr and accept messages with level >= Logging.Debug
debug_logger = ConsoleLogger(stderr, Logging.Debug)
nothing # hide
```

This new logger can now be used instead of the default one  either locally for a task, or
globally, see [Working with loggers](@ref). Examples:

```@repl enable-debug
begin # hide
debug_logger = ConsoleLogger(stderr, Logging.Debug) # hide
with_logger(debug_logger) do # Enable the debug logger locally
     @debug "This is visible now!"
end
end # hide

begin # hide
old_global_logger = global_logger() # hide
debug_logger = ConsoleLogger(stderr, Logging.Debug) # hide
global_logger(debug_logger); # Enable the debug logger globally
global_logger(old_global_logger) # hide
end # hide
with_logger(ConsoleLogger(stderr, Logging.Debug)) do # hide
@debug "This is visible now!"
end # hide
```

The method described above works for any logger that accept the log level as an argument,
however, this is not always the case. An alternative, and more composable, way to enable
debug messages is to use message filtering based on the log level. This is described
in more detail in [How to filter messages](@ref), but an example with log level filtering
is given here using a [`MinLevelLogger`](@ref LoggingExtras.MinLevelLogger).

`MinLevelLogger` is a logger that wraps another logger, but only let messages with high
enough level pass through to the wrapped logger. In this example we wrap a
`ConsoleLogger` that accept every message (`Logging.BelowMinLevel`).

```@example enable-debug2
using Logging, LoggingExtras

begin # hide
logger = MinLevelLogger(
    ConsoleLogger(stderr, Logging.BelowMinLevel),
    Logging.Debug,
)

with_logger(logger) do
    @debug "This is visible!"
end
end # hide
```

To selectively enable debug messages from e.g. certain modules or packages, or filtering
based on things other than the log level, see [How to filter messages](@ref).

### `JULIA_DEBUG` environment variable

Another "quick and dirty" way of enabling debug messages is to make use of the environment
variable `JULIA_DEBUG` (see [Logging/Environmental variables]
(https://docs.julialang.org/en/v1/stdlib/Logging/#Environment-variables)). This variable
can be set to `all`, to enable all debug messages, or to one or more module
names in a comma separated list, to selectively enable debug messages from certain
modules. However, using `JULIA_DEBUG` does not compose as nicely as using proper log
message filtering (see [How to filter messages](@ref)). See for example this issue for some
more discussion and information:
[JuliaLogging/LoggingExtras.jl#20](https://github.com/JuliaLogging/LoggingExtras.jl/issues/20)
.
