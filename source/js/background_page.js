//= require socket.io-client/socket.io
//
//= require nothub-core
//
//= require_tree ./background_scripts

NotHub.IndexRoute = Ember.Route.extend({
});

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

  var event = GitHubEvent.createByType(data);

  new NotHub.createNotification(event.title(), {
    tag:  'github-event-' + event.id,
    icon: event.icon(),
    body: event.message(),
    url:  event.url()
  });
});

// TODO Reload if pong couldn't received
socket.emit('ping', Date.now());
socket.on('pong', function(data) {
  console.log(data);
});
