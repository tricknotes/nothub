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

clearIconCache()
setInterval(clearIconCache, 3 * 24 * 60 * 60 * 1000)

restore = (dataString) ->
  try
    JSON.parse(dataString)
  catch e
    {}

# export for using from other scripts
@updateQuery = updateQuery = () ->
  builder = new QueryBuilder

  usernames = restore(localStorage['username'])
  for name, eventTypes of usernames
    builder.addUsername(name, eventTypes)

  reponames = restore(localStorage['reponame'])
  for name, eventTypes of reponames
    builder.addReponame(name, eventTypes)

  socket.emit 'query', builder.toQuery()

# io.connect is synchronous and heavy wait
# exports is above this line
socket = io.connect('http://stream.nothub.org:4000/', {
  'reconnection delay': 100
  'reconnection limit': 2000
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

socket.on 'error', -> reloader.forceReload
socket.on 'connect', -> reloader.stop
