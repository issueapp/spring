---

    category: Feature Story
    title: Turbine or Not Turbine - That Is The RET Question
    summary: "The last Saturday in November is a warm one and the usually work-boots-only construction compound of Boco Rock Wind Farm is filled with visitors young and old. The ever-impressive women of the CWA are busy in a corner of the airy lunch room assembling mixed plates of a sandwich, half a jam-and-cream scone and a slice—a delicious bargain at $4. Nearby, Bella Cay is blowing out the candles on her 9th birthday cake, and homeschooling mother Nancy Groves is busy gathering information for a study unit devoted to renewable energy."

    videos:
      - url: assets/turbine/cover.mp4
        thumb_url: assets/turbine/cover.jpg
        style: overlay
        cover: true
        autoplay: true
        loop: true
        caption: "Coastal wind farm near Albany, Western Australia"
        
    layout:
      type: custom
      image_style: background
      content_style: black
      custom_class: one-column page-snap
---

<figure class='cover-area video' style="background-image: url({{ cover.thumb_url }})">
  <header>
    <h1 class='title'>{{title}}</h1>
    <h3 class='subtitle'>{{summary}}</h3>
  </header>
  <video src="{{ cover.url }}" type="video/mp4" style="background: {{ cover.thumb_url }} no-repeat; background-size: cover" data-autoplay=true loop></video>
  <figcaption>{{ cover.caption }}</figcaption>
  <a href='geo:-35.042977,117.90521?label=Albany Wind farm' class='show-map'></a>
  <!-- <a href='#page-content' class='page-scroll'><i class='icon-ios7-arrow-down'></i></a> -->
</figure>
