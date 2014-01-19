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

  pollForSyncToFinish = ->
    getSyncs = ->
      $http.get('/repo_syncs').success (syncs) ->
        if syncs.length > 0
          pollForSyncToFinish()
        else
          loadRepos()

    setTimeout getSyncs, 3000

  $scope.activate = (repo) ->
    repo.active = true
    repo.$update()

  $scope.deactivate = (repo) ->
    repo.active = false
    repo.$update()

  $scope.sync = ->
    disableButton()
    $http.post('/repo_syncs').success ->
      pollForSyncToFinish()

  loadRepos()
]
