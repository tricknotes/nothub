NotHub.FollowingUsersController = Ember.ArrayController.extend({
  itemController: 'followingUser',

  username: null,

  actions: {
    follow: function() {
      var username = this.get('username');

      if (!this.store.all('following-user').findBy('id', username)) {
        this.store.createRecord('following-user', {id: username, username: username}).save();
      }

      this.set('username', null);
    }
  }
});
