NotHub.FollowingUsersController = Ember.ArrayController.extend({
  itemController: 'followingUser',

  username: null,

  actions: {
    follow: function() {
      var username = this.get('username');

      if (!this.store.all('following-user').findBy('id', username)) {
        var events = this.store.createRecord('user-event', {id: username});

        this.store.createRecord('following-user', {id: username, username: username, events: events});
      }

      this.set('username', null);
    }
  }
});
