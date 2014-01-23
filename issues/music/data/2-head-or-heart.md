---

    handle: 2-head-or-heart
    title: head or heart
    #author_name: Zyralyn Bacani
    #author_icon: http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png
    image_url: assets/2-head-or-heart/cover.gif
    cover_caption: '[MINKPINK Morrocon Tile Tank and Morrocan Tile Short]'
    images:
      - url: assets/2-head-or-heart/p3-6_opt.jpg

    layout:
      type: three-column
      image_align: right

---
<style>


  h1.title {
    background: url(assets/2-head-or-heart/cover-heading.svg) no-repeat;
    background-size: contain%;
    color: transparent;
    height: 220px;
  }

  p { font-family: "Trebuchet MS", Helvetica, sans-serif}
  big { font-size: 120% }
  p > span { font-style: normal; }

  #header-image {
    position: relative;
    margin-left: -93px;
    max-width: initial;
    width: 310px;
  }
</style>

<span><bold>IN NEED OF A STYLE UPDATE?
  WELL WHAT BETTER TIME
  THAN RIGHT NOW! INSPIRE
  YOUR LOOK WITH THE OFFICIAL
  MINKPINK: THE MUSIC ISSUE
  COLLECTION, STARRING
  CHRISTINA PERRI.</bold></span>

<small>PHOTOGRAPHY BY MIKE PISCITELLI</small>
<small>STYLING BY MARK VASSALLO</small>

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
