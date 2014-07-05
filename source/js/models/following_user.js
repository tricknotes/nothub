NotHub.FollowingUser = DS.Model.extend({
  username: DS.attr(),

  events: DS.attr(null, {
    defaultValue: function() {
      return {
        push:    true,
        star:    true,
        pullreq: true,
        gist:    true,
        others:  true
      };
    }
  }),

  iconURL: '/images/loading.gif',

  fetchUserIcon: Ember.observer('username', function() {
    var username = this.get('username');

    if (!username) {
      return;
    }

    var updateIconURL = this.set.bind(this, 'iconURL');

    $.getJSON('https://api.github.com/users/' + username).then(function(user) {
      updateIconURL(user.avatar_url);
    }).fail(function() {
      updateIconURL('/images/404.png');
    });
  }).on('init')
});
