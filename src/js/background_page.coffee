gravatar_url = (gravatar_id, size)->
  size ||= 140
  "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"

gh_url = (path)->
  "https://github.com/#{path}"

extract_info = (gh_event) ->
  {actor: {login, gravatar_id}, type, repo, payload} = gh_event
  icon = gravatar_id && gravatar_url(gravatar_id)
  [title, message, url] = switch type
    when 'CreateEvent'
      switch payload.ref_type
        when 'branch', 'tag'
          [type, login, gh_url("#{repo.name}/tree/#{payload.ref}")]
        when 'repository'
          [type, login, gh_url(repo.name)]
        else
          console.log([type, gh_event])
          [type, login, repo.name]
    when 'WatchEvent'
      [type, login, gh_url(repo.name)]
    when 'PushEvent'
      [type, login, gh_url("#{repo.name}/commit/#{payload.head}")]
    when 'ForkEvent'
      [type, login, payload.forkee.html_url]
    when 'CommitCommentEvent'
      [type, login, payload.comment.html_url]
    when 'DeleteEvent'
      [type, login, gh_url()] # noop
    when 'GistEvent'
      [type, login, payload.gist.html_url]
    when 'GollumEvent'
      [type, login, payload.pages[0].html_url]
    when 'IssuesEvent'
      [type, login, payload.issue.html_url]
    when 'IssueCommentEvent'
      [type, login, payload.issue.html_url]
    when 'PullRequestEvent'
      [type, login, payload.pull_request.html_url]
    when 'FollowEvent'
      [type, login, payload.target.html_url]
    when 'MemberEvent'
      [type, login, gh_url(repo.name)]
    else
      # for debug
      console.log([type, gh_event])
      JSON.stringify(gh_event)
  {title, message, url, icon}

notify = (gh_event) ->
  {title, message, url, icon} = extract_info(gh_event)
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
