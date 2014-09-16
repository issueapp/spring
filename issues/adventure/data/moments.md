---

    category: "Moments"
    title: "#AcademyMoments"

    thumb_url: assets/moments/3.jpg
    cover_url: assets/moments/3.jpg

    images:
      - url: assets/moments/1.jpg
      - url: assets/moments/2.jpg
      - url: assets/moments/3.jpg
      - url: assets/moments/4.jpg
      - url: assets/moments/5.jpg
      - url: assets/moments/6.jpg
      - url: assets/moments/7.jpg
      - url: assets/moments/8.jpg
      - url: assets/moments/9.jpg

    layout:
      type: custom

---

<div class="content">
  <header>
    <span class="category">Social</span>
    <h1 class="title">#AcademyMoments</h1>
  </header>

  <ul class="polaroids">
  {{#images}}
    <li class="polaroid-wrap">
      <figure class="polaroid">
        <img data-media-id="images:{{ index }}" src="{{ url }}" alt="{{ title }}" title="{{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </li>
  {{/images}}
  </ul>
</div>
