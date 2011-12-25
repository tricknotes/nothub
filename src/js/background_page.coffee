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
          [
            "#{payload.ref_type} created",
            "#{login} created #{payload.ref_type} #{payload.ref} at '#{repo.name}'",
            gh_url("#{repo.name}/tree/#{payload.ref}")
          ]
        when 'repository'
          [
            'Repository created',
            "#{login} created repository '#{repo.name}'",
            gh_url(repo.name)
          ]
        else
          console.log([type, gh_event])
          [type, login, repo.name]
    when 'WatchEvent'
      [
        "Watch started",
        "#{login} started watching #{repo.name}",
        gh_url(repo.name)
      ]
    when 'PushEvent'
      [
        "#{repo.name} was pushed",
        "#{login} pushed to #{payload.ref} at #{repo.name}",
        gh_url("#{repo.name}/commit/#{payload.head}")
      ]
    when 'ForkEvent'
      [
        "#{repo.name} was forked",
        "#{login} forked #{repo.name}",
        payload.forkee.html_url
      ]
    when 'CommitCommentEvent'
      [
        "#{repo.name} was commented",
        "#{login} commented on #{repo.name}",
        payload.comment.html_url
      ]
    when 'DeleteEvent'
      [
        "#{repo.name} was deleted",
        "#{login} deleted #{repo.name}",
        gh_url() # noop
      ]
    when 'GistEvent'
      [
        "Gist #{payload.action}",
        "#{login} #{payload.action} gist: #{payload.gist.id}",
        payload.gist.html_url
      ]
    when 'GollumEvent'
      [
        "Wiki #{payload.pages[0].action}",
        "#{login} #{payload.pages[0].action} the #{repo.name} wiki",
        payload.pages[0].html_url
      ]
    when 'IssuesEvent'
      [
        "Issue #{payload.action}",
        "#{login} #{payload.action} issue #{payload.issue.number} on #{repo.name}",
        payload.issue.html_url
      ]
    when 'IssueCommentEvent'
      [
        "Issue commented",
        "#{login} commented issue #{payload.issue.number} on #{repo.name}",
        payload.issue.html_url
      ]
    when 'PullRequestEvent'
      [
        "Pull request #{payload.action}",
        "#{login} #{payload.action} pull request #{repo.name}",
        payload.pull_request.html_url
      ]
    when 'FollowEvent'
      [
        "#{login} following",
        "#{login} started following #{payload.target.name}",
        payload.target.html_url
      ]
    when 'MemberEvent'
      [
        "Member #{payload.action}",
        "#{login} #{payload.action} #{payload.member.login} to #{repo.name}",
        gh_url(repo.name)
      ]
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
