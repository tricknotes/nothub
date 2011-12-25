gravatar_url = (gravatar_id, size)->
  size ||= 140
  "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"

notify = (gh_event) ->
  {actor: {login, gravatar_id}, type} = gh_event
  icon = gravatar_id && gravatar_url(gravatar_id)
  title = type
  message = login
  notification = webkitNotifications.createNotification(icon, title, message)
  notification.ondisplay = ->
    setTimeout(
      ->
        notification.cancel()
      , 5000
    )
  notification.show()

socket = io.connect('http://www2049u.sakura.ne.jp:4000/')

socket.on 'connected', (data) ->
  console.log(data) # for debug

  socket.on 'gh_event pushed', (data) ->
    console.log(data)
    notify(data)
