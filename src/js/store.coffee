class Store extends EventEmitter
  constructor: (@storage)->
    super()

  add: (type, name, value) ->
    @rewrite(type, name, value)
    @emit('add', type, name)

  remove: (type, name) ->
    @open type, @storage, (data) ->
      delete data[name]
    @emit('remove', type, name)

  update: (type, name, value) ->
    @rewrite(type, name, value)
    @emit('update', type, name)

  items: (type) ->
    @restore(@storage[type])

  # @api private
  restore: (dataString) ->
    try
      JSON.parse(dataString)
    catch e
      {}

  # @api private
  open: (key, storage, callback) ->
    data = @restore(storage[key])
    callback(data)
    storage[key] = JSON.stringify(data)

  # @api private
  rewrite: (type, name, value) ->
    @open type, @storage, (data) ->
      data[name] = value

@Store = Store
