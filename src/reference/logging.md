# Logging.jl

## General usage
```@docs
Logging.@logmsg
Logging.LogLevel
Logging.Debug
Logging.Info
Logging.Warn
Logging.Error
Logging.global_logger
Logging.current_logger
Logging.with_logger
Logging.ConsoleLogger
Logging.SimpleLogger
Logging.NullLogger
```

## Logging interface
```@docs
Logging.AbstractLogger
Logging.min_enabled_level
Logging.shouldlog
Logging.catch_exceptions
Logging.handle_message
```
