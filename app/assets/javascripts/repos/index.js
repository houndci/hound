$('#repo-list').click(function(event) {
  var clickedLink = $(event.target);
  var repoId = clickedLink.data('id');
  var activate = clickedLink.text() == 'on' ? true : false;

  if (activate) {
    $.post('/repo_activations', { github_id: repoId }, function(data) {
      clickedLink.text('off')
    });
  } else {
    $.ajax({
      url: '/repo_activations/' + repoId,
      type: 'delete',
      success: function(data) {
        clickedLink.text('on');
      }
    });
  }
});
