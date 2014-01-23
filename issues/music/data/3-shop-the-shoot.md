---

    title: Get the look
    category: shopping
    image_url: assets/3-shop-the-shoot/cover-white-dress.jpg
    products:

      # Strip top

      - title: MINKPINK All I Need Dress
        url: http://markethq.com/#1
        image_url: assets/3-shop-the-shoot/cream.jpg
        description: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

      - title: Pearl Cat Ear Headband
        url: http://something.com/3456
        image_url: assets/3-shop-the-shoot/IMG_8796.jpg
        description: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

      - title : Indy C Triple Triangle Chain Gold
        url: http://www.surfstitch.com/product/indy-c-triple-triangle-chain-gold
        image_url: assets/3-shop-the-shoot/triangle.jpg
        price: $17.97 AUD
        description: Each season the Indy C team scours the globe & creates a diverse, on-trend range offering unique & affordable pieces that get noticed.

      - title: MINKPINK Losing My Edge
        url: http://markethq.com/#3
        image_url: assets/3-shop-the-shoot/stripe.png
        description: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

      - title: MINKPINK Follow Me To Heaven Playsuit
        url: http://markethq.com/#2
        image_url: assets/3-shop-the-shoot/MP8227i.png
        description: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

      - title: MINKPINK Steamed Up Sunglasses
        url: http://markethq.com/#4
        image_url: assets/3-shop-the-shoot/cover-product-4.jpg
        description: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

    layout:
      type: three-column

---

<style>
/*  .product-set li .tag {
    background: #ff0093;
  }

  .product-set li:nth-child(2n) .tag {
    background: #ff5300;
  }


  .product-set li:nth-child(3n) .tag {
    background: #00ffb2;
  }*/
  /*
  .product-set li:nth-child(4n) .tag {
    background: #00dcff;
  }*/
</style>

<script>
  var colours = ["#00dcff", "#00dcff", "#00ffb2", "#ff0093", "#ff0000", "#fff600"]

  $('.product-set li .tag').each(function () {
    var color = colours[Math.floor(Math.random()*colours.length)];

    $(this).css('background', 'color')
  })
</script>
