---

    category: SHARE YOUR STORY
    title: "#MySpread"

    thumb_url: assets/end/background.jpg
    cover_url: assets/end/background.jpg

    images:
      - url: assets/end/background.jpg
        cover: true
      - url: assets/end/instagram-512.png
        layout: true
      - url: assets/end/story-one-cover.jpg
      - url: assets/end/story-two-cover.jpg
      - url: assets/end/story-three-cover.jpg
      - url: assets/end/story-four-cover.jpg
      - url: assets/end/story-five-cover.jpg
      - url: assets/end/story-six-cover.jpg

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
    <p>Thanks for making time to sit down with Spread.  Each month we will bring you inspiring features about family life and effortless entertaining. In our pages you’ll also find fabulously simple recipes that will get the whole family cooking.</p>

    <h3>
      Share your memories with us on <a href="http://instagram.com/phillyaus"><img src="assets/instagram-512.png" data-media-id="images:2" width="32px">Instagram</a>
    </h3>

    <p class="center">Follow Emily's Food Adventures at <b><a href="http://www.fussfreecooking.com">Fuss Free Cooking</a></b></p>
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
