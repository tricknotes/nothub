class Store
  constructor: (@storage)->
    @ee = new EventEmitter

  add: (type, name) ->
    @ee.emit('add', type, name)
    @storage[type] ||= JSON.stringify([])
    data = JSON.parse(@storage[type])
    data.push(name)
    @storage[type] = JSON.stringify(data)

  remove: (type, name) ->
    @ee.emit('remove', type, name)
    data = JSON.parse(@storage[type])
    if data
      index = data.indexOf(name)
      if index >= 0
        data.splice(index, index + 1)
        @storage[type] = JSON.stringify(data)

  items: (type) ->
    JSON.parse(@storage[type] || '[]')

  on: (args...) ->
    @ee.on(args...)

jQuery ($) ->
  store = new Store(localStorage)

  areaFromType = (type) ->
    areas = $('.watchArea').filter (i, el) ->
      $(el).data('type') == type
    areas[0]

  addNameToWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $place.append(
      $('<li/>').html(
        $('<a/>').text(name)))

  store.on 'add', addNameToWatchedField

  removeNameFromWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $('li', $place).each (i, el)->
      if $(el).text() == name
        $(el).remove()

  store.on 'remove', removeNameFromWatchedField

  $('.watchArea').each (i, area) ->
    type = $(area).data('type')

    # setup submit event
    $('.watchButton', area).click ->
      name = $('.nameInputField', area).attr('value')
      console.log([area, name, type])
      store.add(type, name)

    # setup initialize data
    $.each store.items(type), (i, name) ->
      addNameToWatchedField(type, name)

  # cancel default submit
  $('.watchArea').submit ->
    false
