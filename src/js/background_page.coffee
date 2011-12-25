gravatar_url = (gravatar_id, size)->
  size ||= 140
  "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"

gh_url = (path)->
  "https://github.com/#{path}"

extract_url = (gh_event) ->
  switch gh_event.type
    when 'CreateEvent'
      switch gh_event.payload.ref_type
        when 'branch', 'tag'
          gh_url("#{gh_event.repo.name}/tree/#{gh_event.payload.ref}")
        when 'repository'
          gh_url(gh_event.repo.name)
        else
          console.log([gh_event.type, gh_event])
          gh_event.repo.name
    when 'WatchEvent'
      gh_url(gh_event.repo.name)
    when 'PushEvent'
      gh_url("#{gh_event.repo.name}/commit/#{gh_event.payload.head}")
    when 'ForkEvent'
      gh_event.payload.forkee.html_url
    when 'CommitCommentEvent'
      gh_event.payload.comment.html_url
    when 'DeleteEvent'
      gh_url() # noop
    when 'GistEvent'
      gh_event.payload.gist.html_url
    when 'GollumEvent'
      gh_event.payload.pages[0].html_url
    when 'IssuesEvent'
      gh_event.payload.issue.html_url
    when 'IssueCommentEvent'
      gh_event.payload.issue.html_url
    when 'PullRequestEvent'
      gh_event.payload.pull_request.html_url
    when 'FollowEvent'
      gh_event.payload.target.html_url
    when 'MemberEvent'
      gh_url(gh_event.repo.name)
    else
      # for debug
      console.log([gh_event.type, gh_event])
      JSON.stringify(gh_event)

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
      , 3000
    )
  notification.onclick = ->
    window.open(extract_url(gh_event))
    notification.cancel()

  notification.show()

socket = io.connect('http://www2049u.sakura.ne.jp:4000/')

socket.on 'connected', (data) ->
  console.log(data) # for debug

  socket.on 'gh_event pushed', (data) ->
    console.log(data)
    notify(data)
