App.controller 'ReposController', ['$scope', 'Repo', 'Sync', ($scope, Repo, Sync) ->
  loadRepos = ->
    $scope.syncingRepos = false

    repos = Repo.query()
    repos.$promise.then((results) ->
      $scope.repos = results
    , ->
      alert('Your repos failed to load.')
    )

  initialize = ->
    loadRepos()

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
    $scope.syncingRepos = true

    sync = Sync.save()
    sync.$promise.then(->
      pollSyncStatus()
    , ->
      $scope.syncingRepos = false
      alert('Your repos failed to sync.')
    )

  $scope.$watch 'syncingRepos', (newValue, oldValue) ->
    if newValue
      $scope.syncButtonText = 'Syncing repos...'
    else
      $scope.syncButtonText = 'Sync repos'

  initialize()
]
