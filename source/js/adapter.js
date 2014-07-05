NotHub.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  createRecord: function(store, type, record) {
    var serializedRecord = this.serialize(record, { includeId: true });

    return this.updateStorage(store, type, function(records) {
      records.push(serializedRecord);

      return records;
    });
  },

  updateRecord: function(store, type, record) {
    var id = record.get('id');
    var serializedRecord = this.serialize(record, { includeId: true });

    return this.updateStorage(store, type, function(records) {
      var record = records.findBy('id', id);
      var index  = records.indexOf(record);

      records.replace(index, 1, serializedRecord);

      return records;
    });
  },

  deleteRecord: function(store, type, record) {
    var id = record.get('id');

    return this.updateStorage(store, type, function(records) {
      var record = records.findBy('id', id);

      records.removeObject(record);

      return records;
    });
  },

  find: function(store, type, id) {
    var path    = this.pathForType(type.typeKey);

    var adapter = this;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      adapter.findAll(store, type).then(function(data) {
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
      chrome.storage.sync.get(path, function(data) {
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
  },

  updateStorage: function(store, type, update) {
    var path = this.pathForType(type.typeKey);

    var adapter = this;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      adapter.findAll(store, type).then(function(data) {
        var records = data[path];

        if (!records) {
          records = [];
        }

        data[path] = update(records);

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

});
