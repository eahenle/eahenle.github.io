using HTTP
# start a server listening on port 8081 (default port) for localhost (default host)
# hosts a single page (index.html from the current directory)
HTTP.serve(
    _ -> HTTP.Response(
        200, 
        open("index.html", "r") do f
            return [UInt8(x) for x in read(f)]
        end
    )
)
