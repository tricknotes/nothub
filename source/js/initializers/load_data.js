NotHub.initializer({
  name: 'Load data',

  initialize: function(container) {
    var store = container.lookup('store:main');

    // TODO Load from store.
    store.pushPayload('following-user', {
      following_users: [{
        id: 'tricknotes',
        username: 'tricknotes',
        events: [
          'push',
          'star',
          // 'pullreq',
          // 'gist',
          // 'others'
        ]
      }]
    })
  }
});
