class QueryBuilder
  constructor: () ->
    @query = []

  addUsername: (login, eventTypes) ->
    @query.push({
      actor: {login}
      '$or': @joinQuery(eventTypes, QueryBuilder.userTypes)
    })

  addReponame: (name, eventTypes) ->
    @query.push({
      repo: {name}
      '$or': @joinQuery(eventTypes, QueryBuilder.repoTypes)
    })

  toQuery: () ->
    if @query.length == 1
      @query[0]
    else
      {'$or': @query}

  # @api private
  joinQuery: (eventTypes, allTypes) ->
    query = []
    for {type, toQuery} in allTypes
      if eventTypes[type]
        query.push(toQuery())
    query

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
QueryBuilder.addUserType 'other', ->
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
QueryBuilder.addRepoType 'other', ->
  {type:
    '$nin': [
      'PushEvent'
      'IssueEvent'
      'IssueCommentEvent'
      'PullRequestEvent'
    ]}

@QueryBuilder = QueryBuilder
