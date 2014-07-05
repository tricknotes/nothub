NotHub.FollowingUser = DS.Model.extend({
  username: DS.attr(),
  events:   DS.attr(),

  iconURL: null,

  fetchUserIcon: Ember.observer('username', function() {
    var username = this.get('username');

    if (!username) {
      return null;
    }

    $.getJSON('https://api.github.com/users/' + username).then(function(user) {
      console.log('ok');
      this.set('iconURL', user.avatar_url);
    }.bind(this)).fail(function() {
      console.log('error');
      // TODO Set 404 image.
    }.bind(this));
  }).on('init')
});
