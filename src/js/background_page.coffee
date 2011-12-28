notify = (gh_event_data) ->
  gh_event = GhEvent.create_by_type(gh_event_data)
  notification = webkitNotifications.createNotification(
    gh_event.icon()
    gh_event.title()
    gh_event.message()
  )
  notification.ondisplay = ->
    setTimeout(
      ->
        notification.cancel()
      , 3000
    )
  notification.onclick = ->
    window.open(gh_event.url())
    notification.cancel()

  notification.show()

socket = io.connect('http://www2049u.sakura.ne.jp:4000/')

socket.on 'connected', (data) ->
  updateQuery()
  socket.on 'gh_event pushed', (data) ->
    console.log(data)
    notify(data)

restore = (dataString) ->
  JSON.parse(dataString || '[]')

# export for using from other scripts
@updateQuery = updateQuery = () ->
  builder = new QueryBuilder

  usernames = restore(localStorage['username'])
  for name in usernames
    builder.addUsername(name)

  reponames = restore(localStorage['reponame'])
  for name in reponames
    builder.addReponame(name)

  socket.emit 'query', builder.toQuery()
