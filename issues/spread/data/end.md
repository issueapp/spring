---
    category: SHARE YOUR STORY
    title: "#MySpread"

    thumb_url: assets/end-bg.jpg
    cover_url: assets/end-bg.jpg

    images:
      - url: assets/food-culture/1.jpg
      - url: assets/food-culture/2.jpg
      - url: assets/food-culture/3.jpg

    layout:
      type: custom
      image_style: background
      content_style: transparent

      content_align: left
      content_valign: middle

      custom_class: one-column image-background transparent center middle

---

<figure class="cover-area background" style="background-image: url('assets/end-bg.jpg')"></figure>

<div class="content">
  <header>
    <span class="category">{{ category }}</span>
    <h1 class="title">{{ title }}</h1>
    <p>Thanks for making time to sit down with Spread.  Each month we will bring you inspiring features about family life and effortless entertaining.   In our pages you’ll also find fabulously simple recipes that will get the whole family cooking.  </p>


    <h3>

      Share your memories with us on <img src="assets/instagram-512.png" width="32px">Instagram
    </h3>
    <p>We hope you’ve enjoyed this special Dad’s Day edition of Spread.  We’d love to see what you got up to with the special Dads in your life.  Post your Father’s Day celebration photos on <br/>Instagram, using the hashtag #myspread and using the tag @smudgepublishing to share them with us.  We will select the best photos and publish them in next month’s issue.  </p>
  </header>

  <ul clas="polaroids">
  {{#images}}

    {{^layout}}
    <li class="polaroid-wrap"><a class="">
      <figure class="polaroid">
        <img data-media-id="images:{{ index }}" src="{{ url}}" alt=" {{ title }}" title=" {{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </a>
    {{/layout}}
  {{/images}}
  </ul>

  <div class="body">
  </div>
</div>
