//= require query_builder

NotHub.FollowingUser = DS.Model.extend({
  username: DS.attr(),

  events: DS.attr(null, {
    defaultValue: function() {
      var events = {};

      NotHub.FollowingUser.EVENTS.forEach(function(event) {
        events[event] = true;
      });

      return events;
    }
  }),

  interestingEvents: Ember.computed(function() {
    var events     = this.get('events');
    var eventNames = Object.keys(events);

    return Ember.A(eventNames).filter(function(eventName) {
      return events[eventName];
    });
  }).volatile(),

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

NotHub.FollowingUser.EVENTS = Ember.A(QueryBuilder.userTypes).mapBy('type');

// TODO Make clean!
NotHub.FollowingUser.reopen({
  becomeEventsDirty: Ember.observer.apply(
    null,
    NotHub.FollowingUser.EVENTS.map(function (event) {
      return 'events.' + event;
    }).pushObjects([
    function() {
      this.notifyPropertyChange('data');
      this.send('becomeDirty');
    }])
  )
});
