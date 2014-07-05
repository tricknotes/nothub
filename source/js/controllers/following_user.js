NotHub.FollowingUserController = Ember.ObjectController.extend({
  save: Ember.observer('isDirty', function() {
    if (this.get('isDirty')) {
      this.get('model').save();
    }
  }).on('init'),

  actions: {
    unfollow: function() {
      this.get('model').destroyRecord();
    }
  }
});
