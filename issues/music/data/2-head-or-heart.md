---

    title:
    handle: 2-head-or-heart
    #author_name: Zyralyn Bacani
    #author_icon: http://cl.ly/StPu/Image%202013.12.11%204%3A54%3A01%20pm.png
    image_url: assets/2-head-or-heart/4_opt.jpeg
    description: IN NEED OF A STYLE UPDATE? WELL WHAT BETTER TIME THAN RIGHT NOW! INSPIRE YOUR LOOK WITH THE OFFICIAL MINKPINK: THE MUSIC ISSUE COLLECTION, STARRING CHRISTINA PERRI...
    
    cover_content:
      '
        <a href="#minpink" class="hotspot product"></a>
      '
    
    
    links: 
    
      - title: Test
        description: something else
        url: http://something.com
        hotspot: x,y,radius
        
    products:
    
      - title: something
        description: something
        url: something
        hotspot: x,y,radius
    
    images:
      - url: assets/2-head-or-heart/Head Or Heart album.jpg

    layout:
      type: two-column
      image_align: right

---

<style>
#cp_container_1 {
  position:absolute;
  right: 150px;
  top: 50%;
}
</style>

<img src="assets/2-head-or-heart/cover-heading.svg">

Christina perri walks us through her favourite pieces from the minkpink winter 2014 collection quae voluptatis dolorepero bla aut que volupta ipsunt eiumque consequefdsiquun datecta styling by mark vasallo. photography by mike piscatelli.

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
