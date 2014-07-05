NotHub.initializer({
  name: 'Load data',

  initialize: function(container) {
    var store = container.lookup('store:main');

    // TODO This is the test fixtures. Load from store.
    store.pushPayload('following-user', {
      following_users: [{
        id: 'tricknotes',
        username: 'tricknotes',
        events_id: 'tricknotes',
        // TODO Embed events
        // events: {
        //   id:      'tricknotes',
        //   push:    true,
        //   star:    true,
        //   pullreq: false,
        //   gist:    false,
        //   others:  false
        // }
      }],
      user_events: [{
        id: 'tricknotes',
        push:    true,
        star:    true,
        pullreq: false,
        gist:    false,
        others:  false
      }]
    })
  }
});
