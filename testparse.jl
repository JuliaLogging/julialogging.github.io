macro mac()
    file = __source__.file |> String
    return quote
        println($file)
    end
end




@mac
