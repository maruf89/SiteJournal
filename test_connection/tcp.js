var net = require('net');

// Setup a tcp server
var server = net.createServer(function (socket) {

// Every time someone connects, tell them hello and then close the connection.
socket.addListener("connect", function () {
sys.puts("Connection from " + socket.remoteAddress);
socket.end("Hello World\n");
});

});

// Fire up the server bound to port 7000 on localhost
server.listen(80, "173.234.60.108");

// Put a friendly message on the terminal
console.log("TCP server listening on port 80 at 173.234.60.108");
