GhEvent = (@title, @message, @url) ->

gravatar_url = (gravatar_id, size)->
  size ||= 140
  "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"

gh_url = (path)->
  "https://github.com/#{path}"

GhEvent.handlers = {}

GhEvent.handlers['CreateEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  [title, message, path] = switch payload.ref_type
    when 'branch', 'tag'
      [
        "#{payload.ref_type} created",
        "#{login} created #{payload.ref_type} #{payload.ref} at '#{repo.name}'",
        "#{repo.name}/tree/#{payload.ref}"
      ]
    when 'repository'
      [
        'Repository created',
        "#{login} created repository '#{repo.name}'",
        repo.name
      ]
    else
      console.log([type, gh_event])
      throw "Unknown CreateEvent: #{payload.ref_type}"
  new GhEvent(title, message, gh_url(path))

GhEvent.handlers['WatchEvent'] = (gh_event) ->
  {actor: {login}, repo} = gh_event
  new GhEvent(
    "Watch started"
    "#{login} started watching #{repo.name}"
    gh_url(repo.name)
  )

GhEvent.handlers['PushEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "#{repo.name} was pushed"
    "#{login} pushed to #{payload.ref} at #{repo.name}"
    gh_url("#{repo.name}/commit/#{payload.head}")
  )

GhEvent.handlers['ForkEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "#{repo.name} was forked"
    "#{login} forked #{repo.name}"
    payload.forkee.html_url
  )

GhEvent.handlers['CommitCommentEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "#{repo.name} was commented"
    "#{login} commented on #{repo.name}"
    payload.comment.html_url
  )

GhEvent.handlers['DeleteEvent'] = (gh_event) ->
  {actor: {login}, repo} = gh_event
  new GhEvent(
    "#{repo.name} was deleted"
    "#{login} deleted #{repo.name}"
    gh_url() # noop
  )

GhEvent.handlers['GistEvent'] = (gh_event) ->
  {actor: {login}, payload} = gh_event
  new GhEvent(
    "Gist #{payload.action}"
    "#{login || 'Anonymous'} #{payload.action} gist: #{payload.gist.id}"
    payload.gist.html_url
  )

GhEvent.handlers['GollumEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "Wiki #{payload.pages[0].action}"
    "#{login} #{payload.pages[0].action} the #{repo.name} wiki"
    payload.pages[0].html_url
  )

GhEvent.handlers['IssuesEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "Issue #{payload.action}"
    "#{login} #{payload.action} issue #{payload.issue.number} on #{repo.name}"
    payload.issue.html_url
  )

GhEvent.handlers['IssueCommentEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "Issue commented"
    "#{login} commented issue #{payload.issue.number} on #{repo.name}"
    payload.issue.html_url
  )

GhEvent.handlers['PullRequestEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "Pull request #{payload.action}"
    "#{login} #{payload.action} pull request #{repo.name}"
    payload.pull_request.html_url
  )

GhEvent.handlers['FollowEvent'] = (gh_event) ->
  {actor: {login}, payload} = gh_event
  new GhEvent(
    "#{login} following"
    "#{login} started following #{payload.target.name}"
    payload.target.html_url
  )

GhEvent.handlers['MemberEvent'] = (gh_event) ->
  {actor: {login}, repo, payload} = gh_event
  new GhEvent(
    "Member #{payload.action}"
    "#{login} #{payload.action} #{payload.member.login} to #{repo.name}"
    gh_url(repo.name)
  )

GhEvent.create = (gh_event_data) ->
  {actor: {gravatar_id}, type} = gh_event_data
  handler = @handlers[type]
  unless handler
    console.log([type, gh_event_data])
    throw "Unknown event type: #{type}"
  gh_event = handler(gh_event_data)
  icon = gravatar_id && gravatar_url(gravatar_id)
  gh_event.icon = icon
  gh_event

@GhEvent = GhEvent
