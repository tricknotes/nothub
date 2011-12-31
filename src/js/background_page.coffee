notify = do ->
  notifications = []
  max_count = 3
  timeout = 3000

  (gh_event_data) ->
    gh_event = GhEvent.create_by_type(gh_event_data)
    notification = webkitNotifications.createNotification(
      gh_event.icon()
      gh_event.title()
      gh_event.message()
    )
    notification.ondisplay = ->
      if timeout
        setTimeout(
          ->
            notification.cancel()
          , timeout
        )
    notification.onclick = ->
      window.open(gh_event.url())
      notification.cancel()

    notification.onclose = ->
      if (index = notifications.indexOf(this)) >= 0
        notifications.splice(index, 1)
      for i in [0...max_count]
        notifications[i]?.show()

    notifications.push(notification)

    if notifications.length <= max_count
      notification.show()

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
socket = io.connect('http://www2049u.sakura.ne.jp:4000/')

socket.on 'connected', (data) ->
  updateQuery()

socket.on 'gh_event pushed', (data) ->
  console.log(data)
  notify(data)
