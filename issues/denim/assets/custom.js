$(function() {
  App.on("page:active", function(path) {
    if (path == "perfect-fit/1" || path == "perfect-fit-men/1" || path == "brands-to-love") {
      $('article.page.current').addClass('page-animation');
    }
  });
});
