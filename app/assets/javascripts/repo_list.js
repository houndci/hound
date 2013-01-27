RepoList = function(repos) {
  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  var template = _.template($('#repo-list-item-template').html());

  function buildListItem(repo) {
    var repoListItem = $(template(repo));
    var activateLink = repoListItem.find('a.activate');
    var deactivateLink = repoListItem.find('a.deactivate');
    repoListItem.find('a').hide();

    activateLink.click(function(event) {
      event.preventDefault();
      $.post('/repo_activations', { github_id: repo.id }, function() {
        activateLink.hide();
        deactivateLink.show();
      });
    });

    deactivateLink.click(function(event) {
      event.preventDefault();
      $.ajax({
        url: '/repo_activations/' + repo.id,
        type: 'DELETE',
        success: function() {
          deactivateLink.hide();
          activateLink.show();
        }
      });
    });

    $.get('/repos/' + repo.id, function(data) {
      if (data.active) {
        deactivateLink.show();
      } else {
        activateLink.show();
      }
    });

    return repoListItem;
  }

  return {
    render: function(target) {
      $.each(repos, function(index, repo) {
        listItem = buildListItem(repo);
        target.append(listItem);
      });
    }
  };
};
