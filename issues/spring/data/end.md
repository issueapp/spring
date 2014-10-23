---

    category: SHARE YOUR STORY
    title: "#MySpread"

    thumb_url: assets/end/background.jpg
    cover_url: assets/end/background.jpg

    images:
      - url: assets/end/background.jpg
        cover: true
      - url: assets/story-two/p1-1.jpeg
      - url: assets/story-three/cover.jpg
      - url: assets/story-two/p1-3.jpeg
      - url: assets/story-one/1.jpg
      - url: assets/story-one/2.jpg
      - url: assets/story-one/3.jpg

    layout:
      type: custom
      image_style: background
      content_style: transparent

      content_align: left
      content_valign: middle

      custom_class: one-column image-background transparent black center middle

---

<figure data-media-id="images:1" data-background-image=true class="cover-area background"></figure>

<div class="content">
  <header>
    <span class="category">{{ category }}</span>
    <h1 class="title">{{ title }}</h1>
    <p>Thanks for making time to sit down with Spread.  Each month we will bring you inspiring features about family life and effortless entertaining. In our pages you’ll also find fabulously simple recipes that will get the whole family cooking.  </p>
  </header>

  <ul class="polaroids">
  {{#images}}
    {{^layout}}
    <li class="polaroid-wrap">
      <figure class="polaroid">
        <img src="{{ url }}" alt="{{ title }}" title="{{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </li>
    {{/layout}}
  {{/images}}
  </ul>

  <div class="body">
  </div>
</div>
