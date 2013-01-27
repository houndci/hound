_.templateSettings = {
  interpolate : /\{\{(.+?)\}\}/g
};

RepoList = function(repos) {
  return {
    render: function(target) {
      var template = _.template($('#repo-list-item-template').html());

      $.each(repos, function(index, repo) {
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

        target.append(repoListItem);
      });
    }
  };
};
