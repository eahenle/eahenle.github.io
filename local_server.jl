##! NO SECURITY AT ALL! DO NOT OPEN PORT TO OUTSIDE WORLD!
import HTTP: Response, serve
# start a server listening on localhost:8081
serve() do request
    # validate request
    target = request.target[2:end] # chop off leading '/' from request target
    if target == "" # direct to landing page
        target = "index.html"
    elseif isdir(target)
        target = joinpath(target, "index.html")
    elseif !isfile(target) # look for file
        return Response(404) # file not found
    end
    # serve response
    try # return byte array of file contents
        return open(target, "r") do f
            return Response(200, [UInt8(x) for x in read(f)])
        end
    catch exception
        @error exception target
        return Response(500) # server-side error
    end
    return Response(418) # 🫖
end
