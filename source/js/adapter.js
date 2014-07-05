// TODO Implement these methods using Google Chrome API.
NotHub.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  createRecord: function(store, type, record) {
    var path = this.pathForType(type.typeKey);
    var data = record.serialize();

    return new Ember.RSVP.Promise(function(resolve, reject) {
    });
  },

  // updateRecord: function() {},

  deleteRecord: function(store, type, id) {
    var path = this.pathForType(type.typeKey);

    var findAll = this.findAll.bind(this);

    return new Ember.RSVP.Promise(function(resolve, reject) {
      findAll(store, type).then(function(data) {
        var records = Ember.A(data[path]);
        var record  = records.findBy('id', String(id));

        records.removeObject(record);

        data[path] = records;

        chrome.storage.sync.set(data, function() {
          var error = chrome.extension.lastError;

          if (error) {
            reject(error);
            return;
          }

          resolve();
        });
      });
    });
  },

  find: function(store, type, id) {
    var path    = this.pathForType(type.typeKey);
    var findAll = this.findAll.bind(this);

    return new Ember.RSVP.Promise(function(resolve, reject) {
      findAll(store, type).then(function(data) {
        var records = data[path];
        var record  = Ember.A(records).findBy('id', String(id));

        Ember.assert('`' + type + '(id=' + id + ')` is not found.', record);

        var singleData = {};
        singleData[Ember.String.singularize(path)] = record;

        resolve(singleData);
      });
    });
  },

  findAll: function(store, type) {
    var path = this.pathForType(type.typeKey);

    return new Ember.RSVP.Promise(function(resolve, reject) {
      chrome.storage.sync.get(null, function(data) {
        var error = chrome.extension.lastError;

        if (error) {
          reject(error);
          return;
        }

        if (Ember.typeOf(data[path]) !== 'array') {
          data[path] = [];
        }

        resolve(data);
      });
    });
  },

  findQuery: function(store, type, query) {
    Ember.Logger.log("This adapter doesn't support `findQuery`. Fallback to `findAll`");

    return this.findAll(store, type);
  }
});
