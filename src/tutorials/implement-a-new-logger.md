# Implement a new logger

In this tutorial we will go through the necessary steps for implementing a new logger.
This includes defining a new struct, which is a subtype of `Logging.AbstractLogger`,
and implementing the necessary method for the logger interface.

!!! note
    In general, unless you are implementing a new logger sink, there should be no need
    to define a new logger to get the behavior you want. The [LoggingExtras.jl](@ref)
    package provide loggers for arbitrary routing, transforming, and filtering of log
    events. For example, the logger implemented in this example is trivial to achieve
    using a [`TransformerLogger`](@ref LoggingExtras.TransformerLogger)
    (see the [last section of this page](@ref cipher-existing)).

As a toy example we will implement a cipher logger -- a logger that "encrypts" the message
using a [Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher). We want the logger to
accept any log event, and be configurable with an output stream. Let's get started!

!!! tip
    It is a good idea to follow along by copy-pasting the code snippets into a Julia REPL!

The first step is to load the [Logging.jl](@ref) stdlib which defines the logging
infrastructure and the necessary methods that we need to extend for our new logger.
After that we define the new logger struct, and make sure to use `Logging.AbstractLogger`
as the supertype:

```julia
using Logging

struct CipherLogger <: Logging.AbstractLogger
    io::IO
    key::Int
end

CipherLogger(key::Int=3) = CipherLogger(stderr, key)
```

Input to the logger struct is the I/O stream to which all messages will be written, and
the cipher key, which, for the Caesar cipher, is just an integer. An outer convenience
struct is also defined with some default values: `stderr` for the I/O stream and `3` for
the key.

Next we need to extend the required methods for our new `CipherLogger`:

#### [`Logging.min_enabled_level`](@ref)

This method should return the minimum level for which the logger accepts messages.
The default logger in the Julia REPL only accepts message with level `Logging.Info`
or higher, for example. We want our logger to accept *everything*, so we simply return
`Logging.BelowMinLevel`, which is the smallest possible level:

```julia
Logging.min_enabled_level(logger::CipherLogger) = Logging.BelowMinLevel
```

#### [`Logging.shouldlog`](@ref)

This method is the next chance to filter log messages. The input arguments are the
logger, the log message level, the module where the log event was created, a "group"
which is (by default) the filename in which the log event was created, and a log
event id which is a unique identifier of the location where the event was created.
Based on this information we can decide whether the logger should accept the message
and return `true`, or if it should reject the message and return `false`.
Again, since we want our logger to accept *everything* we simply return `true` regardless
of the input:

```julia
function Logging.shouldlog(logger::CipherLogger, level, _module, group, id)
   return true
end
```

#### [`Logging.catch_exceptions`](@ref)

This method decide whether or not our logger should catch exceptions originating
from the logging system. This can, for example, happen when generating the log message.
If `catch_exceptions` returns `true` the logging system will send a log message to
the logger about the error, and otherwise not. Let's accept those error log messages:

```julia
Logging.catch_exceptions(logger::CipherLogger) = true
```

#### [`Logging.handle_message`](@ref)

This method is where the log event is finally arriving at. The input arguments are the
logger, the log level, the message, and metadata about the source location of the message
(module, group, id, file, and line). In addition, there might be keyword arguments attached
to the log event. For example, from the following:

```julia
@info "hello, world" time = time()
```

the logger would be sent the keyword argument `time => time()` (see the tutorial on
[Logging basics](@ref) for more details). Based on this information we will now
generate a log message and, for our logger, print it to the loggers I/O stream. Of course,
in general this method doesn't  have to write to a regular stream, it could for example
send the log event as an HTTP request (like the [LokiLogger.jl](@ref) package), or send it as a
message to your phone.
The `handle_message` function for our `CipherLogger` below is very simple: we apply
the cipher to the message, and then write out the level and the encrypted message:

```julia
function Logging.handle_message(logger::CipherLogger,
                                lvl, msg, _mod, group, id, file, line;
                                kwargs...)
    # Apply Ceasar cipher on the log message
    msg = caesar(msg, logger.key)
    # Write the formatted log message to logger.io
    println(logger.io, "[", lvl, "] ", msg)
end
```

The only missing part is now the `caesar` function, which should encrypt the message with
the key for the logger. The encryption here is only applied to ASCII letters `A-Z` and `a-z`:

```julia
function caesar(msg::String, key::Int)
    io = IOBuffer()
    for c in msg
        shift = ('a' <= c <= 'z') ? Int('a') : ('A' <= c <= 'Z') ? Int('A') : 0
        if shift > 0
            c = Char((Int(c) - shift + key) % 26 + shift)
        end
        print(io, c)
    end
    return String(take!(io))
end
```

That's it -- we have implemented a new logger! Let's take it for a spin. If you have been
following along, and have copy-pasted the code snippets into a Julia REPL from the start,
you should see the same output as below:

```julia-repl
julia> using Logging

julia> cipher_logger = CipherLogger(3); # new logger with 3 as the key

julia> global_logger(cipher_logger); # set the logger as the global logger

julia> @info "Hello, world!"
[Info] Khoor, zruog!

julia> @info "This is an info message."
[Info] Wklv lv dq lqir phvvdjh.

julia> @warn "This is a warning."
[Warn] Wklv lv d zduqlqj.

julia> @error "This is an error message."
[Error] Wklv lv dq huuru phvvdjh.
```

We can also make sure the our logger accepts log events with level lower than `Logging.Info`
(which e.g. the default logger doesn't):

```julia-repl
julia> @debug "Is this visible?"
[Debug] Lv wklv ylvleoh?
```

Finally, lets make sure that the logger also catches log event exceptions. For example,
here we try to create a message string with a variable `name` which is undefined:

```julia-repl
julia> @info "hello, $name"
[Error] Hafhswlrq zkloh jhqhudwlqj orj uhfrug lq prgxoh Pdlq dw UHSO[17]:1
```

Can you crack the cipher and understand what that means?


### [Build `CipherLogger` using existing functionality](@id cipher-existing)

As indicated in the beginning of this page, unless you are interfacing a new type of logger
sink there is generally no need to implement your own logger. Instead it is better to
compose existing loggers for routing, transforming, and filtering log events. The
`CipherLogger` above can trivially be implemented using a
[`TransformerLogger`](@ref LoggingExtras.TransformerLogger) from the
[LoggingExtras.jl](@ref) package as follows:

```julia
using Logging, LoggingExtras

encryption_logger = TransformerLogger(SimpleLogger(stderr)) do args
    message = caesar(args.message, 3)
    return (; args..., message=message)
end

global_logger(encryption_logger)
```

The result looks as follows:
```julia-repl
julia> @info "hello, world"
┌ Info: khoor, zruog
└ @ Main REPL[5]:1
```

Another advantage of using the already existing `TransformerLogger` is that it composes
nicely. We can therefore decrypt the message with another layer:

```julia
decryption_logger = TransformerLogger(encryption_logger) do args
    message = caesar(args.message, -3) # to decrypt just negate the key
    return (; args..., message=message)
end

global_logger(decryption_logger)
```

Now the messages are encrypted *and* decrypted before printing to the terminal, so in this
case the two loggers just undo each other. Pretty useless, but composability is useful
for many other things!

```julia-repl
julia> @info "hello, world"
┌ Info: hello, world
└ @ Main REPL[8]:1
```
