# How to filter messages

In this tutorial we will see how to filter messages based on the metadata (level, module,
etc.) and the content of log messages. In [How to enable `@debug` messages](@ref) and
[Send messages to multiple locations](@ref) there were examples of how to filter messages
based on the log level, but not based on other things.

Messages can be filtered in two stages during the logging system message plumbing. In the
first stage only the metadata is known (level, module, group, and id). In particular the
message string itself has not been constructed yet. Filtering at this stage can be more
efficient if the log message creation is expensive. For example, in
```julia
@info "The value of some_expensive_call is: $(some_expensive_call(args...))"
```
the call to `some_expensive_call` has not happened yet in the early stage.
Messages can also be filtered later, when more information is available, such as the full
message string, file and line, and any keyword arguments.


### Early filtering using `EarlyFilteredLogger`

Filtering in the early stage can be done with an [`EarlyFilteredLogger`]
(@ref LoggingExtras.EarlyFilteredLogger) from the [LoggingExtras.jl](@ref) package.
The `EarlyFilteredLogger` takes a predicate function and a logger as input arguments.
If the predicate returns `true` the message is passed on to the wrapped logger, otherwise
it is ignored. The predicate function is passed a named tuple, see
[`LoggingExtras.shouldlog_args`](@ref), as the only input.

Here is an example of a logger that only accept (i) messages that are of `Logging.Info` level
(`Logging.Info <= level < Logging.Warn`) and (ii) messages coming from the `Foo` module:

```@example filtering
using Logging, LoggingExtras

# Define the Foo module
module Foo
    info() = @info "Information from Foo"
    warn() = @warn "Warning from Foo"
end
using .Foo

begin # hide
# Create the logger
global_logger() = current_logger() # hide
logger = EarlyFilteredLogger(global_logger()) do args
    r = Logging.Info <= args.level < Logging.Warn && args._module === Foo
    return r
end

# Test it
with_logger(logger) do
    @info "Information from Main"
    @warn "Warning from Main"
    Foo.info()
    Foo.warn()
end
end # hide
```

As you can see, the only message that wasn't dropped by the filter is the `@info` message
from the `Foo` module!

!!! note
    The `MinLevelLogger` is just a special case of an `EarlyFilteredLogger` that only
    checks that the log level of the message is higher than the configured one.

Together with the [`TeeLogger`](@ref LoggingExtras.TeeLogger) we can now create arbitrary
routing for the messages. Here is a more complicated example:

```@example filtering2
using Logging, LoggingExtras

module WebServer end # hide
logger = TeeLogger(
    global_logger(),
    EarlyFilteredLogger(
        args -> args._module === WebServer,
        TeeLogger(
            EarlyFilteredLogger(
                args -> args.level < Logging.Info,
                FileLogger("debug.log"),
            ),
            EarlyFilteredLogger(
                args -> Logging.Info <= args.level < Logging.Warn,
                FileLogger("info.log"),
            ),
            EarlyFilteredLogger(
                args -> Logging.Warn <= args.level,
                FileLogger("warnings_and_errors.log"),
            ),
        )
    ),
)
nothing # hide
```

This logger send all messages to the current global logger and an `EarlyFilteredLogger`.
The `EarlyFilteredLogger` then drops all messages that doesn't come from the module
`WebServer` and send the remaining ones to a new `TeeLogger`. This `TeeLogger` send messages
to three `EarlyFilteredLogger`s that only keep messages of a certain level and send those
to `FileLogger`s corresponding to the level. This means that, in `"debug.log"` there will
only be messages that come from `WebServer` (the first filter) and that have debug log
level. Similarly, in `"info.log"` there will only be messages with info log level, and
any messages with higher level (warn, error) will end up in `"warnings_and_errors.log"`.

### Late filtering using `ActiveFilteredLogger`

In case of filtering based on level, module, group, and id is not enough it is possible
to use an [`ActiveFilteredLogger`](@ref LoggingExtras.ActiveFilteredLogger), also from
the [LoggingExtras.jl](@ref) package. This logger is similar to the `EarlyFilteredLogger`,
with the only difference that the named tuple that the predicate functions is given
contains more data, see [`LoggingExtras.handle_message_args`](@ref). Here is an example
of a logger that filter based on the message string content:

```@example filtering3
using Logging, LoggingExtras

begin # hide
global_logger() = current_logger() # hide
logger = ActiveFilteredLogger(global_logger()) do args
    return args.message == "Hello there!" || args.message == "General Kenobi!"
end

with_logger(logger) do
    @info "I find your lack of faith disturbing."
    @info "Hello there!"
    @info "General Kenobi!"
    @info "Power! Unlimited power!"
end
end # hide
```
