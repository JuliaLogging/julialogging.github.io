# Send messages to multiple locations

In this tutorial we will see how log messages can be sent to multiple locations at the same
time. In e.g. [Working with loggers](@ref) and [How to log to a file](@ref) we saw some
alternative loggers ([`NullLogger`](@ref Logging.NullLogger),
[`FileLogger`](@ref LoggingExtras.FileLogger), etc.) and how to use them. However, in
those examples we made so that messages were sent only to the new logger.
The [LoggingExtras.jl](@ref) package implement a logger for this purpose, the
[`TeeLogger`](@ref LoggingExtras.TeeLogger). The name is inspired by the [shell utility
`tee`](https://en.wikipedia.org/wiki/Tee_(command)) which writes command output to
both standard out and a file.

A very common logging setup is to write logs to both `stderr` (as the default logger does)
*and* a file. Here is how we can do that using a `TeeLogger`, a `FileLogger`, and the
default [`ConsoleLogger`](@ref Logging.ConsoleLogger):

```@example tee
using Logging, LoggingExtras

logger = TeeLogger(
    global_logger(),          # Current global logger (stderr)
    FileLogger("logfile.log") # FileLogger writing to logfile.log
)

nothing # hide
```

When using this logger every message will be routed to *both* the default logger and
to the file. Together with log message filtering it is possible to create arbitrary log
message routing since all the loggers compose nicely and they can be nested.
This is described more in [How to filter messages](@ref), but a short example of this
is given below.

Here is a logger that writes messages to three loggers:
 - The default global logger (stderr),
 - A `MinLevelLogger` accepting any message with level >= `Info` and writing
   them to a file `"logfile.log"` using a `FileLogger`,
 - A `MinLevelLogger` accepting any message with level >= `Debug` and writing
   them to a file `"debug.log"` using a `FileLogger`.

```@example tee2
using Logging, LoggingExtras

logger = TeeLogger(
    # Current global logger (stderr)
    global_logger(),
    # Accept any messages with level >= Info
    MinLevelLogger(
        FileLogger("logfile.log"),
        Logging.Info
    ),
    # Accept any messages with level >= Debug
    MinLevelLogger(
        FileLogger("debug.log"),
        Logging.Debug,
    ),
)

nothing # hide
```
