$(function() {
  App.on("page:active", function(path) {
    if (path.match("gut-instinct")) {
      setTimeout(function() {
        $("a[href='#item1']").click();
      }, 300);
    }
  });

  $(document).on('mouseenter touchstart', ".gut a", function() {
    $("a[href='#item8']").removeAttr('data-hint').removeClass('hint--always');
  });

  $(document).on('click touchstart', ".gut a", function() {
    $('.gut a').removeClass('active');
    $(this).addClass('active');
  });
});
