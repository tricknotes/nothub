NotHub.FollowingListRoute = Ember.Route.extend({
  // model: function() {
  //   
  // },
  setupController: function(controller, model) {
    var usersController = this.controllerFor('following-users');

    this.store.find('following-user').then(function (users) {
      usersController.set('model', users);
    });

    return this._super(controller, model);
  }
});
