class GhEvent
  icon: (size) ->
    size ||= 140
    if gravatar_id = @actor?.gravatar_id
      [
        "https://secure.gravatar.com/avatar/#{gravatar_id}"
        "?s=#{size}"
        "&d=https://a248.e.akamai.net/"
        "assets.github.com%2Fimages%2Fgravatars%2Fgravatar-#{size}.png"
      ].join('')
    else
      null

  gh_url: (path)->
    "https://github.com/#{path}"

  ref_humanized: ->
    @payload.ref.replace(/^refs\/heads\//, '')

GhEvent.create = (gh_event_data) ->
  gh_event = Object.create(gh_event_data)
  for name, method of this.prototype
    gh_event[name] = method
  @apply(gh_event, [])
  gh_event

GhEvent.types = {}
GhEvent.add_type = (type, methods) ->
  Type = class @types[type] extends this

  for name, method of methods
    Type.prototype[name] = method
  Type

# type definitions
GhEvent.add_type 'CommitCommentEvent'
  title: ->
    "#{@repo.name} was commented"
  message: ->
    "#{@actor.login} commented on #{@repo.name}"
  url: ->
    @payload.comment.html_url

GhEvent.add_type 'CreateEvent'
  title: ->
    "#{@payload.ref_type} created"
  message: ->
    message = "#{@actor.login} created #{@payload.ref_type}"
    unless @is_type_of_repository()
      message += " #{@ref_humanized()} at"
    message += " '#{@repo.name}'"
    message
  url: ->
    path = @repo.name
    unless @is_type_of_repository()
      path += "/tree/#{@payload.ref}"
    @gh_url(path)
  is_type_of_repository: ->
    ['branch', 'tag'].indexOf(@payload.ref_type) < 0

GhEvent.add_type 'DeleteEvent'
  title: ->
    "#{@payload.ref_type} was deleted"
  message: ->
    "#{@actor.login} deleted #{@payload.ref_type} #{@ref_humanized()} at #{@repo.name}"
  url: ->
    @gh_url(@actor.login)

GhEvent.add_type 'DownloadEvent'
  title: ->
    "File uploaded"
  message: ->
    "#{@actor.login} uploaded '#{@payload.download.name}' to #{@repo.name}"
  url: ->
    @gh_url(@repo.name)

GhEvent.add_type 'FollowEvent'
  title: ->
    "#{@actor.login} following"
  message: ->
    "#{@actor.login} started following #{@payload.target.login}"
  url: ->
    @payload.target.html_url

GhEvent.add_type 'ForkEvent'
  title: ->
    "#{@actor.login} forked #{@repo.name}"
  message: ->
    "Forked repository is at #{@payload.forkee.owner.login}/#{@payload.forkee.name}"
  url: ->
    @payload.forkee.html_url

GhEvent.add_type 'GistEvent'
  title: ->
    "Gist #{@payload.action}"
  message: ->
    "#{@actor.login || 'Anonymous'} #{@payload.action} gist: #{@payload.gist.id}"
  url: ->
    @payload.gist.html_url

GhEvent.add_type 'GollumEvent'
  title: ->
    "Wiki #{@payload.pages[0].action}"
  message: ->
    "#{@actor.login} #{@payload.pages[0].action} the #{@repo.name} wiki"
  url: ->
    @payload.pages[0].html_url

GhEvent.add_type 'IssueCommentEvent'
  title: ->
    "Issue commented"
  message: ->
    "#{@actor.login} commented issue ##{@payload.issue.number} on #{@repo.name}"
  url: ->
    @payload.issue.html_url

GhEvent.add_type 'IssuesEvent'
  title: ->
    "Issue #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} issue ##{@payload.issue.number} on #{@repo.name}"
  url: ->
    @payload.issue.html_url

GhEvent.add_type 'MemberEvent'
  title: ->
    "Member #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} #{@payload.member.login} to #{@repo.name}"
  url: ->
    @gh_url(@repo.name)

GhEvent.add_type 'PublicEvent'
  title: ->
    "Open sourced"
  message: ->
    "#{@actor.login} open sourced #{@repo.name}"
  url: ->
    @gh_url(@repo.name)

GhEvent.add_type 'PullRequestEvent'
  title: ->
    "Pull request #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} pull request ##{@payload.pull_request.number} on #{@repo.name}"
  url: ->
    @payload.pull_request.html_url

GhEvent.add_type 'PushEvent'
  title: ->
    "#{@repo.name} was pushed"
  message: ->
    "#{@actor.login} pushed to #{@ref_humanized()} at #{@repo.name}"
  url: ->
    if @payload.size <= 1
      @gh_url("#{@repo.name}/commit/#{@payload.head}")
    else
      before = @payload.commits[0].sha.split('')[0...10].join('')
      head = @payload.head
      @gh_url("#{@repo.name}/compare/#{before}%5E...#{head}")

GhEvent.add_type 'TeamAddEvent'
  title: ->
    "Team added"
  message: ->
    "#{@actor.login} added #{@payload.user.login} to #{@payload.team.name}"
  url: ->
    @gh_url(@payload.team.name)

GhEvent.add_type 'WatchEvent'
  title: ->
    "#{@actor.login} starred"
  message: ->
    "#{@actor.login} starred #{@repo.name}"
  url: ->
    @gh_url(@repo.name)

GhEvent.add_type 'PullRequestReviewCommentEvent'
  title: ->
    "Pull request reviewed"
  message: ->
    pull_request_id = @payload.comment._links.pull_request.href.split('/').pop()
    "#{@actor.login} reviewed #{@repo.name} ##{pull_request_id}"
  url: ->
    @payload.comment._links.html.href

GhEvent.create_by_type = (gh_event_data) ->
  {type} = gh_event_data
  event_type = @types[type]
  unless event_type
    console.log([type, gh_event_data])
    throw "Unknown event type: #{type}"
  gh_event = event_type.create(gh_event_data)
  gh_event

# exports
global = if module?.exports? then module.exports else this
global.GhEvent = GhEvent
