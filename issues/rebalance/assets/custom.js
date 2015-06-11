$(function() {
  App.on("page:active", function(path) {
    if (path.match("gut-instinct")) {
      setTimeout(function() {
        $("a[href='#item1']").click();
      }, 300);
    }
  });

  $(document).on('mouseenter touchstart', "a[href='#item8']", function() {
    $(this).removeAttr('data-hint').removeClass('hint--always');
  });
});
