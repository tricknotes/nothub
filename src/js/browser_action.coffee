class Store
  constructor: (@storage)->
    @ee = new EventEmitter

  add: (type, name, value) ->
    @rewrite(type, name, value)
    @ee.emit('add', type, name)

  remove: (type, name) ->
    @open type, @storage, (data) ->
      delete data[name]
    @ee.emit('remove', type, name)

  update: (type, name, value) ->
    @rewrite(type, name, value)
    @ee.emit('update', type, name)

  items: (type) ->
    @restore(@storage[type])

  on: (args...) ->
    @ee.on(args...)

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

background = chrome.extension.getBackgroundPage()

# background page might not be prepared yet
# evaluate updateQuery() during callback execution
updateQuery = -> background.updateQuery()

store = new Store(localStorage)

store.on 'add', updateQuery
store.on 'remove', updateQuery
store.on 'update', updateQuery

# for gravatar
loadGravatarIcon = (type, name, callback) ->
  [apiPath, handler] = switch type
    when 'username'
      [
        "users/#{name}"
        (data) -> callback(data.avatar_url)
      ]
    when 'reponame'
      [
        "repos/#{name}"
        (data) -> callback(data.owner.avatar_url)
      ]
  $.ajax
    url: "https://api.github.com/#{apiPath}"
    dataType: 'json'
    success: handler
    error: ->
      callback('../images/404.png')

# for stream query
supportedEventTypes = {
  username: _.map(QueryBuilder.userTypes, ({type}) -> type )
  reponame: _.map(QueryBuilder.repoTypes, ({type}) -> type )
}

jQuery ($) ->
  $watchArea = $('.watchArea')

  areaFromType = (type) ->
    areas = $watchArea.filter (i, el) ->
      $(el).data('type') == type
    areas[0]

  # template for watched name
  # requires: name, type, eventTypes
  toWatchedArea = _.template($('#watchedAreaTemplate').text())

  setupWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $field = $(toWatchedArea({
      type
      name
      eventTypes: supportedEventTypes[type]
    }))

    # check selected event
    eventTypes = store.items(type)[name]
    $('input[name=eventTypes]', $field).each ->
      if eventTypes[$(this).attr('value')]
        $(this).attr('checked', true)

    # load gravatar icon
    $('img.icon', $field).one 'load', ->
      $img = $(this)
      loadGravatarIcon type, name, (icon) ->
        $img.attr('src', icon)

    $place.append($field)

  store.on 'add', setupWatchedField

  removeNameFromWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $('.watchedRow', $place).each (i, el)->
      if $(el).data('name') == name
        $(el).remove()

  store.on 'remove', removeNameFromWatchedField

  $watchArea.each (i, area) ->
    type = $(area).data('type')

    # setup submit event
    $('.watchButton', area).click ->
      $field = $('.nameInputField', area)
      name = $field.attr('value')
      name = name.replace(/^ +| +$/g, '') # trim
      return unless name
      all = {}
      all[n] = true for n in supportedEventTypes[type]
      store.add(type, name, all)
      $field.attr('value', '')

    # setup initialize data
    for name, _details of store.items(type)
      setupWatchedField(type, name)

  # setup delete link
  $('.deleteWatchedName', $watchArea).live 'click', ->
    $row = $(this).parents('.watchedRow')
    name = $row.data('name')
    type = $row.data('type')
    store.remove(type, name)

  # setup configure link
  $('.configureWatchedName', $watchArea).live 'click', ->
    $row = $(this).parents('.watchedRow')
    $area = $('.configureArea', $row)
    if shown = $(this).data('showArea')
      $area.fadeOut(800)
    else
      $area.fadeIn(1000)
    $(this).data('showArea', !shown)

  # setup configuration area
  $('input[name=eventTypes]', $watchArea).live 'click', ->
    $row = $(this).parents('.watchedRow')
    $area = $(this).parents('.configureArea')
    name = $row.data('name')
    type = $row.data('type')
    checking = {}
    $('input[name=eventTypes]', $area).each ->
      eventType = $(this).attr('value')
      checked = !!$(this).attr('checked')
      checking[eventType] = checked
      true
    store.update(type, name, checking)

  # cancel default submit
  $watchArea.submit ->
    false