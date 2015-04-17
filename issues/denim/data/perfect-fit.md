---

    title: 'Find Your Perfect Fit'

    images:
      - url: 'assets/perfect-fit/p1-1.jpg'
        title: 'Skinny'
        caption: '
          <h2>Skinny</h2>
          <p>A must-have in every woman’s wardrobe, the skinny jeans add height, enhance your natural body shape and never go out of style.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/perfect-fit/p1-2.jpg'
        title: 'Girlfriend'
        caption: '
          <h2>Girlfriend</h2>
          <p>Tighter & higher on the hips than the boyfriend cut, this new fit proves that the right jeans look and feel good.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/perfect-fit/p1-3.jpg'
        title: 'Boyfriend'
        caption: '
          <h2>Boyfriend</h2>
          <p>Loved for its relaxed appeal, the boyfriend jean is the most effortlessly cool staple that can easily be dressed up with pumps.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '
      - url: 'assets/perfect-fit/p1-4.jpg'
        title: 'Flare'
        caption: '
          <h2>Flare</h2>
          <p>Flares are back in this season to add fun curves to your silhouette. It’s the perfect fit to wear over your boots.</p>
          <a href="#" class="button outline">SHOP NOW</a>
        '

    layout:
      type: custom

---

<div class="cover">
  <h1>{{ title }}</h1>
  <ul id="flip-cards" class="no-gutter">

    {{#images}}
    <li class="event col half v-half" ontouchstart="this.classList.toggle('hover')" data-track="hotspot:click">
      <div href="#" class="flipper">
        <div class="image" style='background-image: url({{ url }})'></div>
        <h3>{{ title }}</h3>
        <div class="info">{{{ caption }}}</div>
      </div>
    </li>
    {{/images}}

  </ul>
</div>
