---

    title: Restore Your Balance
    summary: Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quasi fugit quae, reiciendis ut amet voluptatem, vero temporibus sequi fuga quia provident. Atque error rerum, maxime doloribus laboriosam! Quo, quaerat. Deserunt!

    thumb_url: 'assets/placeholder.jpg'

    images:
      - title: Image
        url: assets/story-three/1.jpg

      - title: Image
        url: assets/story-three/2.jpg

      - title: Image
        url: assets/story-three/3.jpg

      - title: Image
        url: assets/story-three/4.jpg

      - title: Image
        url: assets/story-three/5.jpg

      - title: Image
        url: assets/story-three/6.jpg

      - title: Image
        url: assets/story-three/7.jpg

      - title: Image
        url: assets/story-three/8.jpg

      - title: Image
        url: assets/story-three/9.jpg

    custom_html: true

    layout:
      type: three-column
      image_style: cover
      content_align: right
      content_valign: middle

---

<div class="cover col x8">
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

<div class="content col x4">
  <header>
    <h1>{{ title }}</h1>
  </header>
  <div class="body">
    <p>Activia is a probiotic yoghurt which contains probiotic Bifidus ActiRegularis, scientifically proven for its ability to survive in the digestive system and help improve digestive comfort.</p>
    <p>Bifidus ActiRegularis is a probiotic bacteria that has undergone clinical studies and is backed by published scientific studies for its ability to help reduce systems of digestive discomfort such as feeling bloated.</p>
    <p>Made from fresh cow’s milk, Activia is sourced from local Australian farmers and free from gelatin, artificial thickeners or colours.</p>
    <p>Para about Activia in your lifestyle, foods etc leading to recipe/food suggestions.</p>
  </div>
</div>
