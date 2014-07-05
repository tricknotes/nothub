NotHub.FollowingUserController = Ember.ObjectController.extend({
  githubURL: Ember.computed(function() {
    return 'https://github.com/' + this.get('username');
  }).property('username'),

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
