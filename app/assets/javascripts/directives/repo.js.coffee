App.directive 'repo', ->
  scope: true

  templateUrl: '/templates/repo'

  link: (scope, element, attributes) ->
    repo = scope.repo
    scope.processing = false

    activate = ->
      repo.$activate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to activate.'))

    deactivate = ->
      repo.$deactivate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to deactivate.'))

    scope.toggle = ->
      scope.processing = true

      if repo.active
        deactivate(repo)
      else
        activate(repo)
