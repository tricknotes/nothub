class QueryBuilder
  constructor: () ->
    @query = []

  addUsername: (login) ->
    @query.push({actor: {login}})

  addReponame: (name) ->
    @query.push({repo: {name}})

  toQuery: () ->
    if @query.length == 1
      @query[0]
    else
      {'$or': @query}

@QueryBuilder = QueryBuilder
