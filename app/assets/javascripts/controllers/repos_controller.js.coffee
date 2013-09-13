App.controller 'ReposController', ['$scope', 'Repo', ($scope, Repo) ->
  $scope.repos = Repo.query()

  $scope.activate = (repo) ->
    repo.active = true
    repo.$update()

  $scope.deactivate = (repo) ->
    repo.active = false
    repo.$update()
]
