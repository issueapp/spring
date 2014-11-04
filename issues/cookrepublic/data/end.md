---

    category: SHARE YOUR STORY
    title: "#cookrepublic"

    cover_url: assets/end/pantry.jpg
    thumb_url: assets/end/pantry.jpg

    images:
      - url: assets/end/pantry.jpg
      - url: assets/end/award.jpg
      - url: assets/end/kid_biting_giant_cookie.jpg
      - url: assets/end/kid_making_burger.jpg
      - url: assets/end/cookrepublic.jpg
      - url: assets/end/kitchen.jpg
      - url: assets/end/cooking.jpg
      - url: assets/end/kid_making_smoothie.jpg
      - url: assets/end/man_cutting_girder.jpg

    layout:
      type: custom
---

<div class="content">
  <header>
    <h1 class="title">#cookrepublic</h1>
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
</div>
