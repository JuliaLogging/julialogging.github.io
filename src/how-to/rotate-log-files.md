# How to rotate log files

*Log rotation* is common for long running applications such as e.g. a webserver,
see for example [`logrotate`](https://linux.die.net/man/8/logrotate) for Linux systems.
Log rotation means that the logfile is swapped according to some criterion. Usually a
logfile is rotated based on the date, for example daily or weekly, or based on file size,
for example to keep the individual files below 10MB.

## Date based log rotation

The [LoggingExtras.jl](@ref) package implements the [`DatetimeRotatingFileLogger`]
(@ref LoggingExtras.DatetimeRotatingFileLogger) which, as the name suggests, is a logger
for date/time based log rotation. The frequency of log rotation is determined based
on the input filename patterin in the form of a dateformat (see documentation for [`Dates.DateFormat`](https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.DateFormat) and
[`dateformat"..."`](https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.@dateformat_str)).

Let's look at an initial example:

```@example datetime-rotate
using Logging, LoggingExtras

# Directory for our log files
logdir = joinpath(@__DIR__, "logs")
logdir = joinpath(mktempdir(), "logs") # hide
mkpath(logdir)

# Filename pattern (see note below about character escaping)
filename_pattern = raw"yyyy-mm-dd-\w\e\b\s\e\r\v\e\r.\l\o\g"

# Create the logger
logger = DatetimeRotatingFileLogger(logdir, filename_pattern)

old_global_logger = global_logger() # hide
# Install the logger globally
global_logger(logger)
global_logger(old_global_logger) # hide
rm(logdir; recursive=true, force=true) # hide
```

This is a logger that will rotate the log file every day, since "day" is the smallest
datetime unit in the filaname pattern.

!!! note
    Note that all characters in the filename pattern that should not be part of of the
    datetime pattern are escaped. Without this these characters would also be interpreted by
    [`Dates.DateFormat`](https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.DateFormat).
    Technically not all characters need to be escaped, for example `w` doesn't have a
    meaning, but it is safest to escape all characters like in the example above.

Eventually, after some days of logging, we would end up with the following files in our log
directory:

```bash
$ ls logs/
2021-11-12-webserver.log
2021-11-13-webserver.log
2021-11-14-webserver.log
2021-11-15-webserver.log
```

---

Let's now improve the logger by adding two features that are commonly used in `logrotate`:
file compression and file retention policy. Log files are usually quite compressable
and adding compression could save us some space. A file retention policy let us keep log
files for a fixed number of days, for example 30, and then automatically delete them.
Support for compression and retention policies are not built-in, but there are external
packages that we can use for these purposes and implement this functionality in a callback
function using the `rotation_callback` keyword argument. The `DatetimeRotatingFileLogger`
calls this function every time it rotates the log file. The only argument to the function
is the "old" file.

For compression we will use `gzip`, through `Gzip_jll`:

```@example datetime-rotate
using Gzip_jll

function logger_callback(file)
    # Compress the file
    Gzip_jll.gzip() do gzip
        run(`$(gzip) $(file)`)
    end
end
nothing # hide
```

For the file retention policy we will use an `NFileCache` from the
[FilesystemDatastructures](https://github.com/staticfloat/FilesystemDatastructures.jl)
package. Here we create a file cache that keeps 30 files:

```@example datetime-rotate
using FilesystemDatastructures

# Create a file cache that keeps 30 files
fc = NFileCache(logdir, 30, DiscardLRU();
                # Make sure only files ending with "webserver.log.gz" are included
                predicate = x -> endswith(x, r"webserver\.log\.gz")
)
nothing # hide
```

Now we just have to modify the callback above to add rotated and compressed files to the
cache:

```@example datetime-rotate
function logger_callback(file)
    # Compress the file
    Gzip_jll.gzip() do gzip
        run(`$(gzip) $(file)`)
    end
    # Add the compressed file to the cache (gzip adds the .gz extension)
    FilesystemDatastructures.add!(fc, file * ".gz")
end
nothing # hide
```

When the 31th file is added to the cache the oldest file will automatically be deleted to
make room for the new file.
Inspecting the log directory after letting the application run for some time gives us:

```bash
$ ls logs/
2021-11-20-webserver.log.gz
2021-11-21-webserver.log.gz
2021-11-22-webserver.log.gz
[...]
2021-12-17-webserver.log.gz
2021-12-18-webserver.log.gz
2021-12-19-webserver.log.gz
2021-12-20-webserver.log
```

30 compressed files, managed by the cache, and one "active" file yet to be compressed
and added to the cache.

---

Here is the complete example:
```@example datetime-rotate-complete
using Logging, LoggingExtras, Gzip_jll, FilesystemDatastructures

# Directory for our log files
logdir = joinpath(@__DIR__, "logs")
logdir = joinpath(mktempdir(), "logs") # hide
mkpath(logdir)

# Filename pattern
filename_pattern = raw"yyyy-mm-dd-\w\e\b\s\e\r\v\e\r.\l\o\g"

# File cache that keeps 30 files
fc = NFileCache(logdir, 30, DiscardLRU();
                # Make sure only files ending with "webserver.log.gz" are included
                predicate = x -> endswith(x, r"webserver\.log\.gz")
)

# Callback function for compression and adding to cache
function logger_callback(file)
    # Compress the file
    Gzip_jll.gzip() do gzip
        run(`$(gzip) $(file)`)
    end
    # Add the compressed file to the cache (gzip adds the .gz extension)
    FilesystemDatastructures.add!(fc, file * ".gz")
end

# Create the logger
logger = DatetimeRotatingFileLogger(
             logdir, filename_pattern;
             rotation_callback = logger_callback,
)

old_global_logger = global_logger() # hide
# Install the logger globally
global_logger(logger)
global_logger(old_global_logger) # hide
rm(logdir; recursive=true, force=true) # hide
```

!!! note
    The setup above is very similar to the logging setup used by Julia's package servers,
    see [JuliaPackaging/PkgServer.jl:bin/run_server.jl]
    (https://github.com/JuliaPackaging/PkgServer.jl/blob/72e3f280ac0f91d9ded17f23920f0aa3e2a28a89/bin/run_server.jl#L24-L53)

## Filesize based log rotation

For filesize based rotation, e.g. file rotation when the filesize reaches a specific
threshold, checkout the [LogRoller.jl](@ref) package.
