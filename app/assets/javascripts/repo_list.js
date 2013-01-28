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

    function showActivateLink() {
      deactivateLink.hide();
      activateLink.show();
    }

    function showDeactivateLink() {
      activateLink.hide();
      deactivateLink.show();
    }

    activateLink.click(function(event) {
      event.preventDefault();
      var postData = { github_id: repo.id, full_github_name: repo.full_name };
      $.post('/repo_activations', postData, showDeactivateLink);
    });

    deactivateLink.click(function(event) {
      event.preventDefault();
      $.ajax({
        url: '/repo_activations/' + repo.id,
        type: 'DELETE',
        success: showActivateLink
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
