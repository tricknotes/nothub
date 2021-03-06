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

# for stream query
supportedEventTypes = {
  username: QueryBuilder.userTypes.map(({type}) -> type )
  reponame: QueryBuilder.repoTypes.map(({type}) -> type )
}

jQuery ($) ->
  # setup about user area
  $watchAreaAboutUser = $('.watchAreaAboutUser')
  background.getUserName (userName) ->
    $('.watchAreaContent', $watchAreaAboutUser).hide()
    if userName
      $('.loggedIn', $watchAreaAboutUser).show()
      $('img.icon', $watchAreaAboutUser)
        .attr('src', "https://github.com/#{userName}.png")
        .one 'error', ->
          $(this).attr('src', '../images/404.png')

      $checkbox = $('input[type=checkbox]', $watchAreaAboutUser)
      checked = !!store.items('aboutuser')[userName]
      $checkbox.prop('checked', checked)

      $checkbox.on 'change', ->
        if $(this).prop('checked')
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

  # TODO Extract as a JST
  # template for watched name
  # requires: name, type, eventTypes
  toWatchedArea = (context) ->
    configureArea = context.eventTypes.map((eventType) ->
        """
          <label>
            <input name="eventTypes" type="checkbox" value="#{eventType}" />
            #{eventType}
          </label>
        """
      ).join('\n')

    """
      <li class="watchedRow" data-name="#{context.name}" data-type="#{context.type}">
        <a class="iconLink" href="https://github.com/#{context.name}" target="_blank">
          <img class="icon" src="../images/loading.gif" />
        </a>
        <span class="watchedName">
          <a href="https://github.com/#{context.name}" target="_blank">
            #{context.name}
          </a>
        </span>
        <span class="opelation">
          <a class="deleteWatchedName">
            <img src="../images/delete.png" />
          </a>
          <a class="configureWatchedName">
            <img src="../images/config.png" />
          </a>
        </span>
        <div class="configureArea" style="display:none;">
          #{configureArea}
        </div>
      </li>
    """

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
      if eventTypes[$(this).val()]
        $(this).prop('checked', true)

    # load gravatar icon
    $('img.icon', $field)
      .one 'load', ->
        repoName = name.split('/')[0]
        $(this).attr('src', "https://github.com/#{repoName}.png")
      .one 'error', ->
        $(this).attr('src', '../images/404.png')

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
    $(area).on 'click', '.watchButton', ->
      $field = $('.nameInputField', area)
      field = $field.get(0)

      $('.helpBlock', area).empty()
      field.setCustomValidity ''

      unless field.checkValidity()
        field.setCustomValidity $field.attr('title')
        $('.helpBlock', area).html(field.validationMessage)
        return

      name = $field.val()
      name = name.replace(/ +/g, '') # trim
      return unless name # name is empty or whitespace only
      all = {}
      all[n] = true for n in supportedEventTypes[type]
      store.add(type, name, all)
      $field.val('')

    # setup initialize data
    for name, _details of store.items(type)
      setupWatchedField(type, name)

  # setup delete link
  $watchArea.on 'click', '.deleteWatchedName', ->
    $row = $(this).parents('.watchedRow')
    name = $row.data('name')
    type = $row.data('type')
    store.remove(type, name)

  # setup configure link
  $watchArea.on 'click', '.configureWatchedName', ->
    $row = $(this).parents('.watchedRow')
    $area = $('.configureArea', $row)
    if shown = $(this).data('showArea')
      $area.fadeOut(800)
    else
      $area.fadeIn(1000)
    $(this).data('showArea', !shown)

  # setup configuration area
  $watchArea.on 'click', 'input[name=eventTypes]', ->
    $row = $(this).parents('.watchedRow')
    $area = $(this).parents('.configureArea')
    name = $row.data('name')
    type = $row.data('type')
    checking = {}
    $('input[name=eventTypes]', $area).each ->
      eventType = $(this).val()
      checked = !!$(this).prop('checked')
      checking[eventType] = checked
      true
    store.update(type, name, checking)

  # cancel default submit
  $watchArea.submit ->
    false
