App.controller 'ReposController', ['$scope', 'Repo', '$http', ($scope, Repo, $http) ->
  disableButton = ->
    $scope.syncingRepos = true
    $scope.syncButtonText = 'Syncing repos...'

  enableButton = ->
    $scope.syncButtonText = 'Sync repos'
    $scope.syncingRepos = false

  loadRepos = ->
    enableButton()
    $scope.repos = Repo.query()

  $scope.activate = (repo) ->
    repo.active = true
    repo.$update()

  $scope.deactivate = (repo) ->
    repo.active = false
    repo.$update()

  $scope.sync = ->
    disableButton()

    $http.get('/repos/sync').success ->
      eventSource = new EventSource('/repos/events')
      eventSource.addEventListener 'message', (event) ->
        syncFinished = ->
          $scope.syncingRepos && parseInt(event.data, 10) == 0

        if syncFinished()
          loadRepos()

  loadRepos()
]
