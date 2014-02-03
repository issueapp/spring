$(document).on("click", ".popover a", function(e) {
  var isAus = !! App.embed_url && App.embed_url.match(/\/au\//);
  
  var product_title = $('.popover .title').text()
  
  if (isAus && product_title.match(/minkpink/i)) {
    console.log('Popover action clicked', product_title)
    
    window.open("http://minkpink.com/au/store-locator", "_blank");
    
    App.trigger("track", "click", "http://minkpink.com/au/store-locator" )
    
    return false
  }
})

$(function() {
  var isAus = !! App.embed_url && App.embed_url.match(/\/au\//);
  var isShopTheLook = $("article[data-page^='3-shop-the-shoot']").length > 0;
  
  if (isAus) {
    $("article[data-page]").addClass('target-au')
    // 
    // if (isShopTheLook && $('#s4-beauty').length == 0) {
    // 
    //   console.log("something")
    //   
    //     // App.pageView.hotspot.hide(e)
    //     
    // } else {
    //   // var shopTheLookURL = window.location.href.replace(
    //   //   $("article[data-page]").attr("data-page"),
    //   //     "3-shop-the-shoot" );
    //   // 
    //   // $("a.hotspot").on("click", function(e) {
    //   //   window.location = shopTheLookURL;
    //   // });
    // }
  } else {
    $("article[data-page]").addClass('target-global')
  }
});
