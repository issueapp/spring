$(function() {
  var isAus = !! App.embed_url && App.embed_url.match(/\/au\//);
  var isShopTheLook = $("article[data-page^='3-shop-the-shoot']").length > 0;

  if (isAus && $('#s4-beauty').length > 0) {
    $("article[data-page]").addClass('target-au')
    if (isShopTheLook) {

      $("a.hotspot").on("click", function(e) {
        window.open("http://minkpink.com/au/store-locator", "_blank");
        App.pageView.hotspot.hide(e)
      });

    } else {
      var shopTheLookURL = window.location.href.replace(
        $("article[data-page]").attr("data-page"),
          "3-shop-the-shoot" );

      $("a.hotspot").on("click", function(e) {
        window.location = shopTheLookURL;
      });
    }
  } else {
    $("article[data-page]").addClass('target-global')
  }
});
