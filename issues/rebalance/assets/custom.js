$(function() {
  App.on("page:active", function(path) {
    if (path.match("gut-instinct")) {
      setTimeout(function() {
        $("a[href='#item1']").click();
      }, 300)
    }
  });
});
