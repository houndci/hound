//= require angular
//= require angular-resource
//= require namespaced
//= require d3
//= require_self
//= require_tree .

App = angular.module('Hound', ['ngResource']);

App.config(['$httpProvider', function($httpProvider) {
  $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
}]);
