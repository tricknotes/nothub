class QueryBuilder
  constructor: () ->
    @query = []

  addUsername: (login, eventTypes) ->
    @query.push(
      @joinQuery(
        eventTypes
        QueryBuilder.userTypes
        {actor: {login}}
      ))

  addReponame: (name, eventTypes) ->
    @query.push(
      @joinQuery(
        eventTypes
        QueryBuilder.repoTypes
        {repo: {name}}
      ))

  toQuery: () ->
    if @query.length == 1
      @query[0]
    else
      {'$or': @query}

  # @api private
  joinQuery: (eventTypes, allTypes, master) ->
    master ||= {}
    query = []
    allSelected = true
    for {type, toQuery} in allTypes
      if selected = eventTypes[type]
        query.push(toQuery())
      allSelected = allSelected & selected
    unless allSelected
      master['$or'] = query
    master

QueryBuilder.userTypes = []
QueryBuilder.addUserType = (type, toQuery) ->
  @userTypes.push(
    {
      type
      toQuery
    }
  )
QueryBuilder.addUserType 'push', ->
  {type: 'PushEvent'}
QueryBuilder.addUserType 'watch', ->
  {type: 'WatchEvent'}
QueryBuilder.addUserType 'follow', ->
  {type: 'FollowEvent'}
QueryBuilder.addUserType 'pullreq', ->
  {type: 'PullRequestEvent'}
QueryBuilder.addUserType 'gist', ->
  {type: 'GistEvent'}
QueryBuilder.addUserType 'others', ->
  {type:
    '$nin': [
      'PushEvent'
      'WatchEvent'
      'FollowEvent'
      'PullRequestEvent'
      'GistEvent' ]}

QueryBuilder.repoTypes = []
QueryBuilder.addRepoType = (type, toQuery) ->
  @repoTypes.push(
    {
      type
      toQuery
    }
  )
QueryBuilder.addRepoType 'push', ->
  {type: 'PushEvent'}
QueryBuilder.addRepoType 'branch', ->
  {type: 'CreateEvent', payload: {ref_type: 'branch'}}
QueryBuilder.addRepoType 'tag', ->
  {type: 'CreateEvent', payload: {ref_type: 'tag'}}
QueryBuilder.addRepoType 'pullreq', ->
  {type: 'PullRequestEvent'}
QueryBuilder.addRepoType 'issue', ->
  {type: {'$in': ['IssueEvent', 'IssueCommentEvent']}}
QueryBuilder.addRepoType 'others', ->
  {type:
    '$nin': [
      'PushEvent'
      'IssueEvent'
      'IssueCommentEvent'
      'PullRequestEvent'
    ]}

@QueryBuilder = QueryBuilder
