---

    category: SHARE YOUR STORY
    title: "#MySpread"

    thumb_url: assets/end-bg.jpg

    images:
      - url: assets/story-one/p3-1.jpg
      - url: assets/story-one/p3-2.jpg
      - url: assets/story-one/p3-3.jpg
      - url: assets/end-bg.jpg
        cover: true
      - url: assets/instagram-512.png
        layout: true

    layout:
      type: custom
      image_style: background
      content_style: transparent

      content_align: left
      content_valign: middle

      custom_class: one-column image-background transparent black center middle

---

<figure data-media-id="images:4" data-background-image=true class="cover-area background"></figure>

<div class="content">
  <header>
    <span class="category">{{ category }}</span>
    <h1 class="title">{{ title }}</h1>
    <p>Thanks for making time to sit down with Spread.  Each month we will bring you inspiring features about family life and effortless entertaining.   In our pages you’ll also find fabulously simple recipes that will get the whole family cooking.  </p>

    <h3>
      Share your memories with us on <img src="assets/instagram-512.png" data-media-id="images:5" width="32px">Instagram
    </h3>

    <p>We hope you’ve enjoyed this special Dad’s Day edition of Spread.  We’d love to see what you got up to with the special Dads in your life.  Post your Father’s Day celebration photos on Instagram, using the hashtag #myspread and using the tag @smudgepublishing to share them with us.  We will select the best photos and publish them in next month’s issue.  </p>
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
