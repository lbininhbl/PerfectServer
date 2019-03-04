import PerfectHTTP
import PerfectHTTPServer

let networkServer = NetworkServerManager(root: "webroot", port: 8888)
networkServer.startServer()

