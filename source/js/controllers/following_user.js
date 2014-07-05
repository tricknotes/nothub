NotHub.FollowingUserController = Ember.ObjectController.extend({
  actions: {
    unfollow: function() {
      this.get('model.events').destroyRecord();
      this.get('model').destroyRecord();
    }
  }
});
