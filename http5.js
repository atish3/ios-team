var clients = [];
var messages = [];

function (req, res) {
    if (req.method == 'POST') {
        var jsonString = '';

        req.on('data', function (data) {
            jsonString += data;
        });

        req.on('end', function () {
	    var string = JSON.parse(jsonString);
            console.log(string);
	    console.log(`server got: ${string} from ${req.connection.remoteAddress}:${req.connection.remotePort}`);
	    messages.push(jsonString);
	    clients[JSON.stringify([req.connection.remoteAddress, req.connection.remotePort])] = true;
        });
    }
    return jsonString;
}

http.createServer(request, response {
	console.log('server on');
	var body = function(request, response);
	for(

}).listen(3000);
