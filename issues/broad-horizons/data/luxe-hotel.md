---

    category: Utlimate Outback
    title: Arkaba Homestead
    summary: Dating back to the 1850s, Arkaba Homestead's 5 ensuite bedrooms have been tastefully restored in tune with the property's pioneering history.

    images:
      - url: "assets/luxe-hotel/arkaba-homestead.jpg"
        cover: true

    audios:
      - url: "luxe-hotel/jazz-ambient.mp3"
        autoplay: true
        controls: false

    layout:
      type: custom
      image_style: background
      custom_class: one-column page-snap

---
<figure class='cover-area image' style="background-image: url({{ cover_url }})">
  <div class='container col third'>
    <header>
      <span class='category'>{{category}}</span>
      <h1 class='title'>{{title}}</h1>
      <h3 class='subtitle'>{{summary}}</h3>
    </header>
    <audio data-media-id="audios:1"></audio>
  </div>
</figure>
