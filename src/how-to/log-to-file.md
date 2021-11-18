# How to log to a file

!!! tip
    It is a good idea to follow along by copy-pasting the code snippets into a Julia REPL!

Instead of logging to the terminal it is quite common to send log messages to a log file.
Both the [`ConsoleLogger`](@ref Logging.ConsoleLogger) and the
[`SimpleLogger`](@ref Logging.SimpleLogger) from the `Logging` standard library accept an
IO stream as input, so it is pretty easy to plug an open filestream in those loggers and log
to a file. Here is an example:

```@example log-to-file
using Logging

io = open("logfile.txt", "w")
logger = ConsoleLogger(io)

with_logger(logger) do
    @info "Message to the logfile"
end

close(io)
```

When reading the file and printing the result we can verify that the file contains the
expected log output:

```@example
print(read("logfile.txt", String))
rm("logfile.txt") # hide
```

With this approach you might notice that, due to
[IO buffering](https://en.wikipedia.org/wiki/Data_buffer) the messages will be written to
the file with a delay, or possibly not until the program ends and the file is closed.
In addition it is somewhat annoying to manage the file IO stream yourself like in the
example above. Because of these reasons it is often better to use a logger that are
implemented specifically for file-writing.

The [LoggingExtras.jl](@ref) package provide the [`FileLogger`](@ref LoggingExtras.FileLogger),
and, as the name suggest, this is implemented specifically for writing messages to a file.
The `FileLogger` opens the file and automatically flushes the stream after handling each
messages. Here is an example of using the `FileLogger`:

```@example filelogger
using Logging, LoggingExtras

logger = FileLogger("logfile.txt")

with_logger(logger) do
    @info "First message to the FileLogger!"
end
```

Reading and printing the content:

```@example filelogger
print(read("logfile.txt", String))
```

By default, when the `FileLogger` opens the file stream it uses "write" mode (see
documentation for [`open`](https://docs.julialang.org/en/v1/base/io-network/#Base.open)),
which means that if the file exist and have some content this will be overwritten. There is
an option to use "append" mode by passing `append = true` to the constructor. This will
preserve content in the file and only append at the end. Here is an example of that where
we open the same file from above, but use `append = true`:

```@example filelogger

logger = FileLogger("logfile.txt"; append = true)

with_logger(logger) do
    @info "Second message to the FileLogger?"
end

print(read("logfile.txt", String))
rm("logfile.txt") # hide
```

As you can see, the first message is still in the file, and we only appended a second one.

The `FileLogger` uses a [`SimpleLogger`](@ref Logging.SimpleLogger) internally, so the
output formatting is the same as the `SimpleLogger`. If you want to control the output
formatting you can use a [`FormatLogger`](@ref LoggingExtras.FormatLogger) (also from
[LoggingExtras.jl](@ref)) instead. The `FormatLogger` accepts a formatting function as the
first argument. The formatting function takes two arguments: (i) an IO stream to write the
formatted message to and (ii) the logging arguments (see
[`LoggingExtras.handle_message_args`](@ref)). Here is an example:

```@example formatlogger
using Logging, LoggingExtras

logger = FormatLogger(open("logfile.txt", "w")) do io, args
    # Write the module, level and message only
    println(io, args._module, " | ", "[", args.level, "] ", args.message)
end

with_logger(logger) do
    @info "Info message to the FormatLogger!"
    @warn "Warning message to the FormatLogger!"
end

print(read("logfile.txt", String))
rm("logfile.txt") # hide
```

With the `FormatLogger` we need to open the file stream manually with the preferred option
(`"w"`, `"a"`, etc) but, just like the `FileLogger`, it flushes the stream after every
message.

See also:
 - [Send messages to multiple locations](@ref) for how to send log messages to multiple
   loggers, for example to a file *and* to the terminal.
 - [How to rotate log files](@ref) for more file logging options.
