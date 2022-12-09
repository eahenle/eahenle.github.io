using HTTP

function parse_file(filename)
    return open(filename, "r") do f
        return [UInt8(x) for x in read(f)]
    end
end

function server(request)
    if request.target == "/"
        return HTTP.Response(200, parse_file("index.html"))
    elseif request.target == "/data.csv"
        return HTTP.Response(200, parse_file("data.csv"))
    elseif request.target == "/favicon.ico"
        return HTTP.Response(200)
    end

    tokens = split(request.target, "/img/")
    if length(tokens) == 2
        return HTTP.Response(200, parse_file("img/" * tokens[2]))
    end

    return HTTP.Response(400)
end

# start a server listening on port 8081 (default port) for localhost (default host)
# hosts a single page (index.html from the current directory)
HTTP.serve(server)
