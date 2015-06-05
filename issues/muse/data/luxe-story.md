---

    category: Utlimate Stay
    title: Arkaba Homestead
    summary: Dating back to the 1850s, Arkaba Homestead's 5 ensuite bedrooms have been tastefully restored in tune with the property's pioneering history.

    thumb_url: "assets/luxe-story/arkaba-homestead.jpg"
    
    images:
      - url: "assets/luxe-story/arkaba-homestead.jpg"
        cover: true

    audios:
      - url: "assets/luxe-story/jazz-ambient.mp3"
        autoplay: true
        controls: false

    custom_html: true

    layout:
      type: custom
      image_style: background
      content_style: black
      custom_class: one-column page-snap

---

<figure class='cover-area image' style="background-image: url({{ cover.url }})" data-background-cover="true" >
  <div class='container col third'>
    <header>
      <span class='category'>{{category}}</span>
      <h1 class='title'>{{title}}</h1>
      <h3 class='subtitle'>{{summary}}</h3>
    </header>
    <audio data-media-id="audios:1"></audio>
  </div>
  <a href="#" class="audio audio-on"></audio>
</figure>
