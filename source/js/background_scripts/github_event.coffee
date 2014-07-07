class GitHubEvent
  icon: ->
    @actor.avatar_url

  ghUrl: (path)->
    "https://github.com/#{path}"

  humanizedRef: ->
    @payload.ref.replace(/^refs\/heads\//, '')

GitHubEvent.create = (ghEventData) ->
  ghEvent = Object.create(ghEventData)
  for name, method of this.prototype
    ghEvent[name] = method
  @apply(ghEvent, [])
  ghEvent

GitHubEvent.types = Object.create(null)
GitHubEvent.registerType = (type, methods) ->
  Type = class @types[type] extends this

  for name, method of methods
    Type.prototype[name] = method
  Type

# type definitions
GitHubEvent.registerType 'CommitCommentEvent',
  title: ->
    "#{@repo.name} was commented"
  message: ->
    "#{@actor.login} commented on #{@repo.name}"
  url: ->
    @payload.comment.html_url

GitHubEvent.registerType 'CreateEvent',
  title: ->
    "#{@payload.ref_type} created"
  message: ->
    messages = ["#{@actor.login} created #{@payload.ref_type}"]
    unless @isTypeOfRepository()
      messages.push("'#{@humanizedRef()}' at")
    messages.push(@repo.name)
    messages.join(' ')
  url: ->
    path = @repo.name
    unless @isTypeOfRepository()
      path += "/tree/#{@payload.ref}"
    @ghUrl(path)
  isTypeOfRepository: ->
    ['branch', 'tag'].indexOf(@payload.ref_type) < 0

GitHubEvent.registerType 'DeleteEvent',
  title: ->
    "#{@payload.ref_type} was deleted"
  message: ->
    "#{@actor.login} deleted #{@payload.ref_type} '#{@humanizedRef()}' at #{@repo.name}"
  url: ->
    @ghUrl(@actor.login)

GitHubEvent.registerType 'DownloadEvent',
  title: ->
    "File uploaded"
  message: ->
    "#{@actor.login} uploaded '#{@payload.download.name}' to #{@repo.name}"
  url: ->
    @ghUrl(@repo.name)

GitHubEvent.registerType 'FollowEvent',
  title: ->
    "#{@actor.login} following"
  message: ->
    "#{@actor.login} started following #{@payload.target.login}"
  url: ->
    @payload.target.html_url

GitHubEvent.registerType 'ForkEvent',
  title: ->
    "#{@actor.login} forked #{@repo.name}"
  message: ->
    "Forked repository is at #{@payload.forkee.owner.login}/#{@payload.forkee.name}"
  url: ->
    @payload.forkee.html_url

GitHubEvent.registerType 'GistEvent',
  title: ->
    "Gist #{@payload.action}"
  message: ->
    "#{@actor.login || 'Anonymous'} #{@payload.action} gist: #{@payload.gist.id}"
  url: ->
    @payload.gist.html_url

GitHubEvent.registerType 'GollumEvent',
  title: ->
    "Wiki #{@payload.pages[0].action}"
  message: ->
    "#{@actor.login} #{@payload.pages[0].action} the #{@repo.name} wiki"
  url: ->
    @payload.pages[0].html_url

GitHubEvent.registerType 'IssueCommentEvent',
  title: ->
    "Issue commented"
  message: ->
    "#{@actor.login} commented issue ##{@payload.issue.number} on #{@repo.name}"
  url: ->
    @payload.issue.html_url

GitHubEvent.registerType 'IssuesEvent',
  title: ->
    "Issue #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} issue ##{@payload.issue.number} on #{@repo.name}"
  url: ->
    @payload.issue.html_url

GitHubEvent.registerType 'MemberEvent',
  title: ->
    "Member #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} #{@payload.member.login} to #{@repo.name}"
  url: ->
    @ghUrl(@repo.name)

GitHubEvent.registerType 'PublicEvent',
  title: ->
    "Open sourced"
  message: ->
    "#{@actor.login} open sourced #{@repo.name}"
  url: ->
    @ghUrl(@repo.name)

GitHubEvent.registerType 'PullRequestEvent',
  title: ->
    "Pull request #{@payload.action}"
  message: ->
    "#{@actor.login} #{@payload.action} pull request ##{@payload.pull_request.number} on #{@repo.name}"
  url: ->
    @payload.pull_request.html_url

GitHubEvent.registerType 'PushEvent',
  title: ->
    "#{@repo.name} was pushed"
  message: ->
    "#{@actor.login} pushed to branch '#{@humanizedRef()}' at #{@repo.name}"
  url: ->
    if @payload.size <= 1
      @ghUrl("#{@repo.name}/commit/#{@payload.head}")
    else
      before = @payload.commits[0].sha.split('')[0...10].join('')
      head = @payload.head
      @ghUrl("#{@repo.name}/compare/#{before}%5E...#{head}")

GitHubEvent.registerType 'TeamAddEvent',
  title: ->
    "Team added"
  message: ->
    "#{@actor.login} added #{@payload.user.login} to #{@payload.team.name}"
  url: ->
    @ghUrl(@payload.team.name)

GitHubEvent.registerType 'WatchEvent',
  title: ->
    "#{@actor.login} starred"
  message: ->
    "#{@actor.login} starred #{@repo.name}"
  url: ->
    @ghUrl(@repo.name)

GitHubEvent.registerType 'PullRequestReviewCommentEvent',
  title: ->
    "Pull request reviewed"
  message: ->
    pullRequestNumber = @payload.comment._links.pull_request.href.split('/').pop()
    "#{@actor.login} reviewed #{@repo.name} ##{pullRequestNumber}"
  url: ->
    @payload.comment._links.html.href

GitHubEvent.createByType = (ghEventData) ->
  {type} = ghEventData
  eventType = @types[type]
  unless eventType
    console.log([type, ghEventData])
    throw "Unknown event type: #{type}"
  ghEvent = eventType.create(ghEventData)
  ghEvent

# exports
global = if module?.exports? then module.exports else this
global.GitHubEvent = GitHubEvent
