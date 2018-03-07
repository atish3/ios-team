
const http = require('http');

var clients = [];

http.createServer((request, response) => {
	console.log(request);

	 request.on('error', (err) => {
   		 console.error(err);
   		 response.statusCode = 400;
   		 response.end();
  		});
	const { headers, method, url } = request;
 	 let body = [];
 	 request.on('error', (err) => {
 	   console.error(err);
 	 }).on('data', (chunk) => {
 	   body.push(chunk);
 	 }).on('end', () => {
 	   	body = Buffer.concat(body).toString();
	   	response.on('error', (err) => {
           		console.error(err);
    		});

    		response.statusCode = 200;


}).listen(3000);	

