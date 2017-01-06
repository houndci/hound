$(document).ready(function() {
  $('.quick-jump').change( function () {
    var targetPosition = $($(this).val()).offset().top - 120;
    $('html,body').animate({ scrollTop: targetPosition}, 400);
  });
});
