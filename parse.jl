str = """
a = 1 + 2
b = a + 3
error()
@info "hello"
"""

exprs = []
start = 1

while true
    ex, next_start = Meta.parse(str, start)
    ex === nothing && break

    stop = prevind(str, next_start)

    ex, _ = Meta._parse_string("begin; " * str[start:stop] * "; end", "REPL", 1, :statement)
    push!(exprs, ex)

    start = next_start
end


