NotHub.FollowingListRoute = Ember.Route.extend({
  // model: function() {
  //   
  // },
  setupController: function(controller, model) {
    this.controllerFor('following-users')
      .set('model', this.store.all('following-user'))

    return this._super(controller, model);
  }
});
