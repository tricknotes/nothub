//= require socket.io-client/socket.io
//
//= require nothub-core
//= require gh_event

NotHub.IndexRoute = Ember.Route.extend({
});

// TODO

var socket = io.connect('http://stream.nothub.org:5000/', {
  'reconnection delay': 500,
  'reconnection limit': 10000,
  'max reconnection attempts': Infinity
});

socket.on('connect', function() {
  console.log('- connected!');
});

window.notifyQueryChange = function(query) {
  console.log(query);
  socket.emit('query', query);
};

socket.on('gh_event pushed', function(data) {
  // TODO Notify!
  console.log(data);
});

// TODO Reload if pong couldn't received
socket.emit('ping', Date.now());
socket.on('pong', function(data) {
  console.log(data);
});
