$(document).ready(function() {
  $(window).on("scroll touchmove", function () {
    $('.global-header.repo-index').toggleClass('shrunk', $(document).scrollTop() > 0);
  });
});
