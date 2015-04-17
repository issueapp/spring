$(function() {
  App.on("page:active", function(path) {
    if (path == "perfect-fit" || path == "brands-to-love") {
      $('article.page.current #flip-cards .flipper').eq(0).addClass('flip');
    }
  });
});
