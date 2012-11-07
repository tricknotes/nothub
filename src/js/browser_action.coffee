background = chrome.extension.getBackgroundPage()

# background page might not be prepared yet
# evaluate updateQuery() during callback execution
updateQuery = -> background.updateQuery()

store = new Store(localStorage)

store.on 'add', updateQuery
store.on 'remove', updateQuery
store.on 'update', updateQuery

# user icons
iconCache = new Store(localStorage)

# for gravatar
loadGravatarIcon = (type, name, callback) ->
  if info = iconCache.items('usericon')[name]
    callback(info.avatar_url || info.owner.avatar_url)
  [apiPath, handler] = switch type
    when 'username', 'aboutuser'
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
    success: (data) ->
      iconCache.add('usericon', name, data)
      handler(data)
    error: ->
      callback('../images/404.png')

# for stream query
supportedEventTypes = {
  username: _.map(QueryBuilder.userTypes, ({type}) -> type )
  reponame: _.map(QueryBuilder.repoTypes, ({type}) -> type )
}

jQuery ($) ->
  # setup about user area
  $watchAreaAboutUser = $('.watchAreaAboutUser')
  background.getUserName (userName) ->
    $('.watchAreaContent', $watchAreaAboutUser).hide()
    if userName
      $('.loggedIn', $watchAreaAboutUser).show()
      loadGravatarIcon 'aboutuser', userName, (icon) ->
        $('img.icon', $watchAreaAboutUser).attr('src', icon)

      $checkbox = $('input[type=checkbox]', $watchAreaAboutUser)
      checked = !!store.items('aboutuser')[userName]
      $checkbox.attr('checked', checked)

      $checkbox.change ->
        if $(this).attr('checked')
          store.add('aboutuser', userName, true)
        else
          store.remove('aboutuser', userName)

    else # not logged in
      $('.loggedOut', $watchAreaAboutUser).show()

  $watchArea = $('.watchArea')

  areaFromType = (type) ->
    areas = $watchArea.filter (i, el) ->
      $(el).data('type') == type
    areas[0] # nothing to duplicate

  # template for watched name
  # requires: name, type, eventTypes
  toWatchedArea = (context) ->
    [
      '<li class="watchedRow" data-name="' + context.name + '" data-type="' + context.type + '">'
      ' <a class="iconLink" href="https://github.com/' + context.name + '" target="_blank">'
      '   <img class="icon" src="../images/loading.gif" />'
      ' </a>'
      ' <span class="watchedName">'
      '   <a href="https://github.com/' + context.name + '" target="_blank">'
      context.name
      '   </a>'
      ' </span>'
      ' <span class="opelation">'
      '   <a class="deleteWatchedName">'
      '     <img src="../images/delete.png" />'
      '   </a>'
      '   <a class="configureWatchedName">'
      '     <img src="../images/config.png" />'
      '   </a>'
      ' </span>'
      ' <div class="configureArea" style="display:none;">'
      _(context.eventTypes).map((eventType) ->
        [
          '<label>'
          '<input name="eventTypes" type="checkbox" value="' + eventType + '" />'
          eventType
          '</label>'
        ].join('\n')
      ).join('\n')
      ' </div>'
      '</li>'
    ].join('\n')

  setupWatchedField = (type, name) ->
    return unless supportedEventTypes[type]
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
    return unless supportedEventTypes[type]
    $place = $('.watchedNames', areaFromType(type))
    $('.watchedRow', $place).each (i, el) ->
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
      return unless name # name is empty or whitespace only
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
