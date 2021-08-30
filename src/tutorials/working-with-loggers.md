# Working with loggers

!!! tip
    It is a good idea to follow along by copy-pasting the code snippets into a Julia REPL!

In this tutorial we will learn how to work with loggers, i.e. the backends that receives
and handles the log messages emitted by `@info` and friends (see [Logging basics](@ref)).

The default logger in Julia is a [`ConsoleLogger`](@ref Logging.ConsoleLogger) that prints
log messages to the terminal (specifically it prints to
[`stderr`](https://docs.julialang.org/en/v1/base/io-network/#Base.stderr)).

```@repl
@info "Hello default ConsoleLogger!"
```

The `ConsoleLogger` is just one implementation of a logger backend but there are many other
backends for various purposes, see for example the [Logging package overview](@ref). In this
tutorial we will only try out the loggers that are defined in the [Logging.jl](@ref)
standard library, but the functions for working with loggers are the same no matter which
logger implementation you use.

The [`global_logger`](@ref Logging.global_logger) function can be used to get or set the
*global logger*:
```@repl
using Logging
global_logger() = current_logger() # hide
global_logger() |> typeof
```

The current global logger is inherited by any spawned tasks so if you want to set a custom
logger for your program it is usually enough to update the global logger. Here is an
example of how to set the global logger to a [`NullLogger`](@ref Logging.NullLogger) to
silence all log messages:

```@repl
using Logging
logger = NullLogger();
old_logger = global_logger(logger); # save the old logger
with_logger(NullLogger()) do # hide
@info "This message goes to the new global NullLogger!"
end # hide
global_logger(old_logger); # reset to the old logger
@info "This message goes to the old logger again!"
```

As you can see in the example, the `global_logger` function returns the old logger when a
new one is set and we then reset the global logger to the old one. For a program/application
this is usually all you need -- you construct a logger, or a combination of loggers, and
set the global logger to this one.

With the [`with_logger`](@ref Logging.with_logger) function it is possible to change the
logger for a specific task.

```@repl
using Logging
logger = NullLogger();
with_logger(logger) do
    @info "This message goes to the temporary logger!"
end
@info "Now the logger is back to normal."
```

As you can see, after the call to `with_logger` the logger state is unchanged and the
log message is displayed as usual.
