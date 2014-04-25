App.factory 'Repo', ['$resource', ($resource) ->
  Repo = $resource '/repos/:id', {id: '@id'},
    activate:
      method: 'POST', url: 'repos/:id/activation'
    deactivate:
      method: 'POST', url: 'repos/:id/deactivation'

  Repo.prototype.toggle = ->
    @processing = true
    if @active
      deactivate(@)
    else
      activate(@)

  activate = (repo) ->
    repo.$activate()
      .then(-> repo.processing = false)
      .catch(-> alert('Your repo failed to activate.'))

  deactivate = (repo) ->
    repo.$deactivate()
      .then(-> repo.processing = false)
      .catch(-> alert('Your repo failed to deactivate.'))

  Repo
]
