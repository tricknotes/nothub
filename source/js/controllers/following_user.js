NotHub.FollowingUsersController = Ember.ArrayController.extend({
  username: null,

  actions: {
    follow: function() {
      var username = this.get('username');
      console.log(username);

      this.set('username', null);
    }
  }
});
