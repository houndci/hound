$('#repo-list').click(function(event) {
  var clickedLink = $(event.target);
  var githubId = clickedLink.data('github-id');
  var activate = clickedLink.text() == 'on' ? true : false;

  if (activate) {
    $.post('/repo_activations', { github_id: githubId }, function(data) {
        clickedLink.text('off')
      }
    );
  } else {
    $.ajax({
      url: '/repo_activations/' + githubId,
      type: 'DELETE',
      success: function(data) {
        clickedLink.text('on');
      }
    });
  }
});
