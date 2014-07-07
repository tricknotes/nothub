NotHub.ApplicationRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    var usersController = this.controllerFor('following-users');
    var queryController = this.controllerFor('query');

    this.store.find('following-user').then(function (users) {
      usersController.set('model', users);
      queryController.set('followingUsers', users);
    });

    return this._super(controller, model);
  }
});
