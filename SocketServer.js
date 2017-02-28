var net = require('net');

var server = net.createServer(function(socket){

	
	socket.on('data',function(data){

		socket.write(data);
	});

	socket.on('end',function(data){

		console.log('server will disconnect');

	});
});

server.on('connection',function(client){

	client.name = client.remoteAddress + ':' + client.remotePort;
	client.write('Hi' + client.name + '!\n');

});

server.listen(8888,function(){

	console.log('server bind');
});