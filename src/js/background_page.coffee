store = new Store(localStorage)
Object.defineProperty store, 'config', {
    get: ->
      store.items('config')
  }

notify = do ->
  notifications = []

  showNotification = ->
    max_count = Number(store.config['maxNotificationCount']) || 3
    for i in [0...max_count]
      notifications[i]?.show()

  (gh_event_data) ->
    gh_event = GhEvent.create_by_type(gh_event_data)
    notification = webkitNotifications.createNotification(
      gh_event.icon()
      gh_event.title()
      gh_event.message()
    )
    notification.ondisplay = ->
      if timeout = Number(store.config['notificationTimeout'])
        setTimeout(
          ->
            notification.cancel()
          , timeout * 1000 # milli sec to sec
        )
    notification.onclick = ->
      window.open(gh_event.url())
      notification.cancel()

    notification.onclose = ->
      if (index = notifications.indexOf(this)) >= 0
        notifications.splice(index, 1)
      showNotification()

    notifications.push(notification)
    showNotification()

clearIconCache = ->
  console.log('icon cache expired')
  delete localStorage.usericon

setInterval(clearIconCache, 3 * 24 * 60 * 60 * 1000)

restore = (dataString) ->
  try
    JSON.parse(dataString)
  catch e
    {}

@getUserName = getUserName = (callback)->
  xhr = new XMLHttpRequest()
  xhr.onreadystatechange = ->
    if xhr.readyState == 4 # contents loaded
      container = document.createElement('div')
      container.innerHTML = xhr.responseText
      userNameElement = container.querySelector('#user')
      userName = if userNameElement
        userNameElement.textContent.replace(/^[ \n]+|[ \n]+$/g, '')
      else
        null
      callback(userName)
  xhr.open('GET', 'https://github.com')
  xhr.send()

# export for using from other scripts
@updateQuery = updateQuery = () ->
  builder = new QueryBuilder

  usernames = restore(localStorage['username'])
  for name, eventTypes of usernames
    builder.addUsername(name, eventTypes)

  reponames = restore(localStorage['reponame'])
  for name, eventTypes of reponames
    builder.addReponame(name, eventTypes)

  aboutUser = store.items('aboutuser')
  if aboutUser && (Object.keys(aboutUser).length > 0)
    getUserName (userName) ->
      if userName && aboutUser[userName]
        builder.addAboutUser(userName)
      socket.emit 'query', builder.toQuery()
  else
    socket.emit 'query', builder.toQuery()

# io.connect is synchronous and heavy wait
# exports is above this line
socket = io.connect('http://stream.nothub.org:4000/', {
  'reconnection delay': 500
  'reconnection limit': 10000
  'max reconnection attempts': Infinity
})

socket.on 'connect', ->
  updateQuery()

socket.on 'gh_event pushed', (data) ->
  console.log(data)
  notify(data)

# auto reload
reloader =
  reloadId: null
  reconnect: ->
    location.href = location.href # bad hack
  forceReload: ->
    @stop()
    @reloadId = setTimeout(@reconnect, 3000)
  stop: ->
    if reloadId = @reloadId
      clearInterval(reloadId)
  access_time: new Date
  ping_interval: 10 * 60 * 1000
  is_overed: (date) ->
    diff = date.getTime() - @access_time.getTime()
    diff > @ping_interval * 1.5

socket.on 'pong', (data) ->
  reloader.access_time = new Date(data)

setInterval ->
  socket.emit('ping', new Date)
, reloader.ping_interval

setInterval ->
  if reloader.is_overed(new Date)
    reloader.forceReload()
, reloader.ping_interval * 1.1

socket.on 'error', -> reloader.forceReload()
socket.on 'connect', -> reloader.stop()
