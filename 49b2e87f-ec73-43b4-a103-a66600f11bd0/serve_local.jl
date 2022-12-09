using HTTP

function response(request)
    filename = request.target[2:end] # chop off leading '/' from request target
    if !isfile(filename) # look for file -- return "file not found" if it doesn't exist
        return HTTP.Response(404)
    end
    ##! SECURITY DANGER ZONE
    ##! This will allow access to ANY FILE.
    ##! e.g. http://localhost:8081//home/user/.ssh/known_hosts
    ##! may also be vulnerable to string interpolation
    ##! DO NOT USE THIS EXCEPT FOR LOCAL TESTING
    try
        return open(filename, "r") do f
            return HTTP.Response(200, [UInt8(x) for x in read(f)])
        end
    catch exception
        @error exception
        return HTTP.Response(500)
    end
end

# start a server listening on port 8081 (default port) for localhost (default host)
# hosts a single page (index.html from the current directory)
HTTP.serve() do request
    if request.target == "/"
        return HTTP.Response(200, parse_file("index.html"))
    elseif request.target == "/data.csv"
        return HTTP.Response(200, parse_file("data.csv"))
    elseif request.target == "/favicon.ico"
        return HTTP.Response(200)
    elseif request.target == "/style.css"
        return HTTP.Response(200, parse_file("style.css"))
    end

    tokens = split(request.target, "/img/")
    if length(tokens) == 2
        return HTTP.Response(200, parse_file("img/" * tokens[2]))
    end

    @warn "??" request # console log unhandled requests

    return HTTP.Response(418) # I'm a teapot
end
