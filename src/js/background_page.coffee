notify = (gh_event_data) ->
  {title, message, url, icon} = GhEvent.create(gh_event_data)
  notification = webkitNotifications.createNotification(icon, title, message)
  notification.ondisplay = ->
    setTimeout(
      ->
        notification.cancel()
      , 3000
    )
  notification.onclick = ->
    window.open(url)
    notification.cancel()

  notification.show()

socket = io.connect('http://www2049u.sakura.ne.jp:4000/')

socket.on 'connected', (data) ->
  socket.on 'gh_event pushed', (data) ->
    console.log(data)
    notify(data)
