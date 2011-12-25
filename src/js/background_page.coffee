gravatar_url = (gravatar_id, size)->
  size ||= 140
  "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"

extract_info = (gh_event_data) ->
  {actor: {gravatar_id}} = gh_event_data
  icon = gravatar_id && gravatar_url(gravatar_id)
  gh_event = GhEvent.create(gh_event_data)
  gh_event.icon = icon
  gh_event

notify = (gh_event_data) ->
  {title, message, url, icon} = extract_info(gh_event_data)
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
