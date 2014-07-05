// TODO Implement these methods using Google Chrome API.
NotHub.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  // find: function() {},

  createRecord: function(store, type, record) {
    return Ember.RSVP.resolve();
  },

  // updateRecord: function() {},

  deleteRecord: function() {
    return Ember.RSVP.resolve();
  },

  // findAll: function() {},
  // findQuery: function() {}
});
