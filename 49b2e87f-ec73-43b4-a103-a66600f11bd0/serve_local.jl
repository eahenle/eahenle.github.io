##! SECURITY DANGER ZONE
##! DO NOT USE THIS EXCEPT FOR LOCAL TESTING
##! EVEN THEN, PROCEED WITH CAUTION

import HTTP: Response, serve

# start a server listening on port 8081 (default port) for localhost (default host)
serve() do request
    filename = request.target[2:end] # chop off leading '/' from request target
    if filename == "" # top-level request; direct to landing page
        filename = "index.html"
    elseif !isfile(filename) # look for file
        return Response(404) # file not found
    end
    
    try # return byte array of file contents
        return open(filename, "r") do f
            return Response(200, [UInt8(x) for x in read(f)])
        end
    catch exception
        @error exception
        return Response(500) # server-side error
    end

    return Response(418) # I'm a teapot
end
