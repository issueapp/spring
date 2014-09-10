---

    category: "Social"
    title: "#AJL Spotted"
    thumb_url: assets/spotted/3.jpg

    images:
      - url: assets/spotted/1.jpg
      - url: assets/spotted/2.jpg
      - url: assets/spotted/3.jpg
      - url: assets/spotted/4.jpg
      - url: assets/spotted/5.jpg
      - url: assets/spotted/6.jpg
      - url: assets/spotted/7.jpg
      - url: assets/spotted/8.jpg

    layout:
      nav: true
      type: custom

---

<div class="content">
  <header>
    <span class="category">{{ category }}</span>
    <h1 class="title">{{ title }}</h1>
  </header>

  <ul class="polaroids">
  {{#images}}
    <li class="polaroid-wrap">
      <figure class="polaroid">
        <img data-media-id="{{ index }}" src="{{ url }}" alt="{{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </li>
  {{/images}}
  </ul>
</div>
