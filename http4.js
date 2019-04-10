// our dependencies
const express = require('express');
const app = express();

var clients = [];
var messages = [];

// from top level path e.g. localhost:3000, this response will be sent
app.get('/', (request, response) =>{
	 for (var client in clients){
		for (var message in messages) {
			JSON.stringify([message]);
			response.send(message);
		}
	}
});

app.use(bodyParser.urlencoded({
    extended: true
}));


app.use(bodyParser.json());


app.post('/', (request, response) => {
	console.log(`server got: ${request} from ${request.connection.remoteAddress}:${request.connection.remotePort}`);
	console.log(request.body.text)
	clients[JSON.stringify([request.connection.remoteAddress, request.connection.remotePort])] = true;
	messages.push(request);
	response.send('get now');
	for(var message in messages){
		console.log(message);
	}
});

// set the server to listen on port 3000
app.listen(3000, () => console.log('Listening on port 3000'));
