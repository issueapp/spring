---

    category: "Operabar Moments"
    title: "#LoveOperaBar"

    thumb_url: assets/end/5.jpg
    cover_url: assets/end/5.jpg

    images:
      - title: Opera Bar
        url: assets/end/1.jpg

      - title: Opera Bar
        url: assets/end/2.jpg

      - title: Opera Bar
        url: assets/end/3.jpg

      - title: Opera Bar
        url: assets/end/4.jpg

      - title: Opera Bar
        url: assets/end/5.jpg
        cover: true

      - title: Opera Bar
        url: assets/end/6.jpg

      - title: Opera Bar
        url: assets/end/7.jpg

      - title: Opera Bar
        url: assets/end/8.jpg

      - title: Opera Bar
        url: assets/end/9.jpg

    layout:
      type: custom

---

<div class="content">
  <header>
    <h1 class="title">{{ title }}</h1>
  </header>
  <ul class="polaroids">
  {{#images}}
    <li class="polaroid-wrap">
      <figure class="polaroid">
        <img src="{{ url }}" alt="{{ title }}" title="{{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </li>
  {{/images}}
  </ul>
</div>
