function respondify(){
  $('iframe[src*="embed.spotify.com"]').each( function() {
    $(this).css('width',$(this).parent().css('width'));
    $(this).attr('src',$(this).attr('src'));
  });
}


$(function() {
  App.on("page:active", function(path) {
    respondify()

    if (path == "perfect-fit/1" || path == "perfect-fit-men/1" || path == "brands-to-love") {

      setTimeout(function() {
        $('article.page.current').addClass('page-animation');
      }, 1000)
    }
  });
});
