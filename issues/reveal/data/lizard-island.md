---

    title: Lizard Island
    summary: 'Great Barrier Reef'

    images:
      - url: 'assets/lizard-island/brand.png'
      - url: 'assets/lizard-island/island.jpg'
        cover: true

    audios:
      - url: "assets/luxe-story/jazz-ambient.mp3"
        autoplay: true
        controls: false

    custom_html: true

    layout:
      type: one-column
      content_style: black

---

<div class="content">
  <div class="body">
    <img class="brand" data-media-id="images:1" src="assets/lizard-island/brand.png" data-original >

    <figure class="island" style="background-image: url({{ cover.url }})" >
      <h1>Experience<br>24 Private<br>Beaches</h1>
    </figure>

    <div class="booking row">
      <div class="col x8">
        <p>Like No Where Else</p>
        <a href="http://lizardisland.com.au" target="_blank">www.lizardisland.com.au</a>
      </div>
      <div class="col x4">
        <a href="http://lizardisland.com.au" class="button outline" target="_blank">Book Now</a>
      </div>
    </div>
  </div>
</div>

<audio data-media-id="audios:1"></audio>
<a href="#" class="audio audio-on"></audio>
<a href='geo:-31.648238,139.013542?label=Flinders Range' class='show-map pull-left'></a>
