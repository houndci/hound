App.controller 'ReposController', ['$scope', 'Repo', 'Sync', ($scope, Repo, Sync) ->
  disableButton = ->
    $scope.syncingRepos = true
    $scope.syncButtonText = 'Syncing repos...'

  enableButton = ->
    $scope.syncButtonText = 'Sync repos'
    $scope.syncingRepos = false

  loadRepos = ->
    enableButton()

    repos = Repo.query()
    repos.$promise.then((results) ->
      $scope.repos = results
    , ->
      alert('Your repos failed to load.')
    )

  pollSyncStatus = ->
    getSyncs = ->
      syncs = Sync.query()
      syncs.$promise.then((results) ->
        if results.length > 0
          pollSyncStatus()
        else
          loadRepos()
      , ->
        pollSyncStatus()
      )

    setTimeout getSyncs, 3000

  $scope.activate = (repo) ->
    repo.active = true
    repo.$update()

  $scope.deactivate = (repo) ->
    repo.active = false
    repo.$update()

  $scope.sync = ->
    disableButton()

    sync = Sync.save()
    sync.$promise.then(->
      pollSyncStatus()
    , ->
      enableButton()
      alert('Your repos failed to sync.')
    )

  loadRepos()
]
