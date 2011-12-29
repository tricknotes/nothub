class Store
  constructor: (@storage)->
    @ee = new EventEmitter

  add: (type, name) ->
    @storage[type] ||= JSON.stringify([])
    data = JSON.parse(@storage[type])
    data.push(name)
    @storage[type] = JSON.stringify(data)
    @ee.emit('add', type, name)

  remove: (type, name) ->
    data = JSON.parse(@storage[type])
    if data
      index = data.indexOf(name)
      if index >= 0
        data.splice(index, 1)
        @storage[type] = JSON.stringify(data)
    @ee.emit('remove', type, name)

  items: (type) ->
    JSON.parse(@storage[type] || '[]')

  on: (args...) ->
    @ee.on(args...)

background = chrome.extension.getBackgroundPage()
{updateQuery} = background

store = new Store(localStorage)

store.on 'add', updateQuery
store.on 'remove', updateQuery

jQuery ($) ->
  areaFromType = (type) ->
    areas = $('.watchArea').filter (i, el) ->
      $(el).data('type') == type
    areas[0]

  # template for watched name
  # requires: name, type
  toWatchedArea = _.template '''
    <li data-name="<%- name %>">
      <a href="https://github.com/<%- name %>" target="_blank">
        <%- name %>
      </a>
      <a href="#" class="deleteWatchedName" data-name="<%- name %>" data-type="<%- type %>">
        [x]
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
      name = name.replace(/^ +| +$/g, '') # trim
      return unless name
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
