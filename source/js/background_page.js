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
