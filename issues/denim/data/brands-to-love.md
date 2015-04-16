---

    title: 'Brands To Love'
    summary: 'What is your inspiration?'

    images:
      - url: 'assets/brands-to-love/Levis.jpg'
        title: 'Levis'
        caption: '
          <h2>Levis</h2>
          <p>A must-have in every woman’s wardrobe, the skinny jeans add height, enhance your natural body shape and never go out of style.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Nobody-Jeans.jpg'
        title: 'Nobody Jeans'
        caption: '
          <h2>Nobody Jeans</h2>
          <p>Tighter & higher on the hips than the boyfriend cut, this new fit proves that the right jeans look and feel good.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Ziggy.jpg'
        title: 'Ziggy'
        caption: '
          <h2>Ziggy</h2>
          <p>Loved for its relaxed appeal, the boyfriend jean is the most effortlessly cool staple that can easily be dressed up with pumps.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Mavi-Jeans.jpg'
        title: 'Mavi Jeans'
        caption: '
          <h2>Mavi Jeans</h2>
          <p>Flares are back in this season to add fun curves to your silhouette. It’s the perfect fit to wear over your boots.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Jack-Jones.jpg'
        title: 'Jack Jones'
        caption: '
          <h2>Jack Jones</h2>
          <p>Flares are back in this season to add fun curves to your silhouette. It’s the perfect fit to wear over your boots.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Gstar-raw.jpg'
        title: 'Gstar Raw'
        caption: '
          <h2>Gstar Raw</h2>
          <p>Flares are back in this season to add fun curves to your silhouette. It’s the perfect fit to wear over your boots.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '

    layout:
      type: custom

---

<div class="cover">
  <header>
    <h1>Brands To <b>Love</b></h1>
    <p class="summary">{{ summary }}</p>
  </header>

  <ul id="flip-cards" class="no-gutter">

    {{#images}}
    <li class="event col half v-half" ontouchstart="this.classList.toggle('hover')" data-track="hotspot:click" title="{{ title }}">
      <div href="#" class="flipper">
        <div class="image" style='background-image: url({{ url }})'></div>
        <div class="info">{{{ caption }}}</div>
      </div>
    </li>
    {{/images}}

  </ul>
</div>
