//= require nothub

NotHub.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('following-list');
  }
});

NotHub.Router.map(function() {
  this.route('following-list');
});
