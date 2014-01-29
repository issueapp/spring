---

    handle: 1-styling-it-out
    category: 'Christina Perri:'
    title: Styling it out
    image_url: assets/1-styling-it-out/MinkPink_ChristinaPerri_0005-31_opt.jpeg
    cover_caption: '<a class="hotspot product" href="http://www1.bloomingdales.com/buy/mink-pink?cm_sp=shop_by_brand-_-ALL%20DESIGNERS-_-MINK%20PINK">Minkpink Paisley Crush Dress.</a>'

    layout:
      type: three-column
      image_align: right

    products:
    
      - title: MINKPINK Paisley Crush Dress 
        url: http://www1.bloomingdales.com/buy/mink-pink?cm_sp=shop_by_brand-_-ALL%20DESIGNERS-_-MINK%20PINK
        image_url: assets/1-styling-it-out/MinkPink_ChristinaPerri_0005-31_opt.jpeg
        price: 1
        description: SHOP THE MINKPINK COLLECTION
        hidden: true
---

<style>
  article.page[data-page="1-styling-it-out"] .content {
    position: relative;
  }

  /*  Replace page heading with outline heading (change background url or height if needed) */
  h1.title {
    height: 150px;
    background: url(assets/1-styling-it-out/STYLINGITOUT.svg) no-repeat;
    background-size: 100%;
    color: transparent;
  }

  article.page[data-page="1-styling-it-out"] .cp-container {
    position: absolute;
    top: 0;
    left: 50%;
    margin-top: -25px;
    margin-left: -100px;
  }

  article.page[data-page="1-styling-it-out"] .cp-container ul {
    padding-left: 25px;
  }


  article.page[data-page="1-styling-it-out"] header  {
    padding-top: 130px;
  }

  article.page[data-page="1-styling-it-out"] header .category {
    top: 200px;
    margin-top: 200px;
    color: black;
    text-align: left;
    font-size: 36px;
    font-family: 'rodondoregular';
  }
</style>

August in California, and L.A’s tribe of Beautiful People are flocking to the beaches in their hoards…but for one talented young singer-songwriter, there’s no better place to while away the days than the recording studio. It’s here that Philly-born rock chick and style maven Christina Perri feels most at home, so it made perfect sense to choose North Hollywood’s iconic Mates Studios as the location to shoot MINKPINK’s brand new global campaign <em>The Music Issue</em>, fronted by the stunning songstress herself.

<div id="jquery_jplayer_1" class="cp-jplayer"></div>

<div id="cp_container_1" class="cp-container">
  <div class="cp-buffer-holder"> <!-- .cp-gt50 only needed when buffer is > than 50% -->
    <div class="cp-buffer-1"></div>
    <div class="cp-buffer-2"></div>
  </div>
  <div class="cp-progress-holder"> <!-- .cp-gt50 only needed when progress is > than 50% -->
    <div class="cp-progress-1"></div>
    <div class="cp-progress-2"></div>
  </div>
  <div class="cp-circle-control"></div>
  <ul class="cp-controls">
    <li><a class="cp-play" tabindex="1">play</a></li>
    <li><a class="cp-pause" style="display:none;" tabindex="1">pause</a></li> <!-- Needs the inline style here, or jQuery.show() uses display:inline instead of display:block -->
  </ul>
</div>

<script>
  var myCirclePlayer = new CirclePlayer("#jquery_jplayer_1",{
    m4a: "/music/assets/Christina Perri - I Believe.m4a"
  },
  {
    cssSelectorAncestor: "#cp_container_1",
    canplay: function() {
      $("#jquery_jplayer_1").jPlayer("play");
    }
  });
</script>
