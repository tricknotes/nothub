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

  toWatchedArea = _.template '''
    <li data-name="<%- name %>">
      <a><%- name %></a>
      <a href="#" class="deleteWatchedName" data-name="<%- name %>" data-type="<%- type %>">
        Delete
      </a>
    </li>
  '''

  addNameToWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $place.append(toWatchedArea({type, name}))

  store.on 'add', addNameToWatchedField

  removeNameFromWatchedField = (type, name) ->
    $place = $('.watchedNames', areaFromType(type))
    $('li', $place).each (i, el)->
      if $(el).data('name') == name
        $(el).remove()

  store.on 'remove', removeNameFromWatchedField

  $('.watchArea').each (i, area) ->
    type = $(area).data('type')

    # setup submit event
    $('.watchButton', area).click ->
      $field = $('.nameInputField', area)
      name = $field.attr('value')
      store.add(type, name)
      $field.attr('value', '')

    # setup initialize data
    $.each store.items(type), (i, name) ->
      addNameToWatchedField(type, name)

  # setup delete link
  $('.watchArea .deleteWatchedName').live 'click', ->
    name = $(this).data('name')
    type = $(this).data('type')
    store.remove(type, name)

  # cancel default submit
  $('.watchArea').submit ->
    false
