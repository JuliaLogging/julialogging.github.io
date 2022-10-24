# Logging basics

In this tutorial we will learn the basics of how to emit *log messages* or *log events*.
We will also learn a bit about what information each message consists of and what happens
after the log message is emitted. If you are writing a script or a package this section
should cover everything you need.

!!! tip
    It is a good idea to follow along by copy-pasting the code snippets into a Julia REPL!

### Basic log events

The most important information in a log event is the *log message* and the *log level*.
The log message is usually an informative text string and the log level is a severity level
indicating to the reader how important the log message is.
Julia's `Base` module, which is available by default, provides the logging macros `@info`,
`@warn`, `@error`, and `@debug` for creating log messages. These correspond to common log
message levels:

- **Info**: useful information but nothing critical
- **Warning**: information about something that might not be right
- **Error**: information about something that went wrong
- **Debug**: extra information useful when debugging

Let's look at how we can create some log messages using the macros mentioned above:

```@repl
@info "This is an info message, carry on as usual."
@warn "This is a warning message, something might be wrong?"
@error "This is an error message, something is not working as it should!"
@debug "This is a debug message, it is invisible!"
printstyled("\njulia>"; color=:green, bold=true) # hide
```

As you can see, for simple usage we only need the macro, which determines the log level,
and the message string. The default logging backend, responsible for handling the
log messages that we generate, prints a formatted, colored, message to the terminal as in
the example above. The formatting is different depending on the log level: `@info`-messages
don't print out location info (module, file, line number) like `@warn`- and `@error`-
messages does. You can also note that `@debug`-messages are off by default. Typically you
would only turn on those when you need more information such as when debugging an issue
with your code.


### Adding extra metadata to the log event

In the examples above the only information we passed to the logging macros where the log
message string. It is possible to pass along more information by attaching additional
things after the message string. Extra information can be added using `key = value` syntax
like this:

```@repl
@info "hello, world" x = [1, 2, 3] y = "something else"
```

or by just attaching a variable like this:

```@repl
x = [3, 4, 5];
@info "hello, world" x
```

In both cases you can see that the logging backend formatted the extra information nicely
below the log message string. Adding extra information can be useful in many cases, and in
particular if you want to keep the message string constant while still passing some dynamic
information.


### Log levels

The four logging levels `Info`, `Warn`, `Error`, and `Debug` are just aliases for specific
numeric levels on the allowed log level range as you can see in the table below:

| Level    | Alias                   | Comment                         |
|:--------:|:------------------------|:--------------------------------|
| -1000001 | `Logging.BelowMinLevel` | (below) lowest possible level   |
| -1000    | `Logging.Debug`         | log level for `@debug` messages |
| 0        | `Logging.Info`          | log level for `@info` messages  |
| 1000     | `Logging.Warn`          | log level for `@warn` messages  |
| 2000     | `Logging.Error`         | log level for `@error` messages |
| 1000001  | `Logging.AboveMaxLevel` | (above) highest possible level  |

The Logging module, which comes with Julia, provides the [`@logmsg`](@ref Logging.@logmsg)
macro, which is a generalization of the other macros mentioned so far. In addition to the
message string it is also required to pass a log level to when using this macro, but other
than that `@logmsg` works the same. Here are some examples:

```@repl logmsg
using Logging
@logmsg Logging.Info "Info message from @logmsg."
@logmsg Logging.Error "Error message from @logmsg." x = [1, 2, 3]
```

With the `@logmsg` macro it is also possible to create log messages with any level using
the `LogLevel` constructor:

```@repl logmsg
@logmsg Logging.LogLevel(123) "Log message with log level 123."
@logmsg Logging.LogLevel(1234) "Log message with log level 1234."
@logmsg Logging.LogLevel(2345) "Log message with log level 2345."
```

From the coloring of the output we can deduce that log level 123 is a `Info`-message, log
level 1234 is a `Warn`-message, and log level 2345 is a `Error`-message. You can also see
this with the help of the table above: a log message with level `X` is a:
 - debug message if `Logging.Debug <= X < Logging.Info`,
 - info message if `Logging.Info <= X < Logging.Warn`,
 - warn message if `Logging.Warn <= X < Logging.Error`,
 - error message if `Logging.Error <= X < Logging.AboveMaxLevel`.

Custom log level like this is not very common, but sometimes it is handy with some more
fine grained control.


### Location metadata

In the logging output above you see some other metadata attached to the message. In
particular, the source module, the filename and line number of the log event is displayed.
Since the code is running in the Julia REPL the module is `Main`, the "file" is `REPL[..]`
and the line simply `1`. Every log event generated with the macros mentioned above gets
assigned the following metadata:
 - the source module,
 - the source file,
 - the source line,
 - a log event id (unique to the location),
 - a log event group (the filename by default).

It is up to the log message backend to choose what to do with this information. For example,
the default logger backend in the Julia REPL shows no metadata for `@info` messages, and
only shows the module, file, and line for other messages. It is possible to override the
default, for example to change the apparent source location. To do this you would pass
keyword arguments to the log message macros:

```@repl
@warn "Overriding the source module" _module = Base
@warn "Overriding the source file" _file = "example.jl"
@warn "Overriding the source line" _line = 123
@warn "Overriding the log event group" _group = :example
@warn "Overriding the log event id" _id = :id
```

Since the default logger backend only shows the module, file, and line the other overrides
are not visible.
