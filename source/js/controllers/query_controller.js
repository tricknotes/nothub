NotHub.QueryController = Ember.ArrayController.extend({
  followingUsers: null,

  background: Ember.computed(function() {
    return chrome.extension.getBackgroundPage();
  }),

  queryDidChange: Ember.observer('followingUsers.@each.isDirty', function() {
    Ember.run.debounce(this, 'notifyQueryChange', this.get('background').notifyQueryChange, 100);
  }),

  notifyQueryChange: function(callback) {
    var builder        = new QueryBuilder();
    var followingUsers = this.get('followingUsers');

    followingUsers.forEach(function(user) {
      builder.addUsername(
        user.get('username'),
        user.get('interestingEvents')
      )
    });

    callback(builder.toQuery());
  }
});
