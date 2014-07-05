NotHub.FollowingUserController = Ember.ObjectController.extend({
  actions: {
    unfollow: function() {
      this.get('model').destroyRecord();
    }
  }
});
