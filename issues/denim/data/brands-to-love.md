---

    title: 'Brands To Love'
    summary: 'What is your inspiration?'
    thumb_url: 'assets/brands-to-love/cover.jpg'
    cover_url: 'assets/brands-to-love/cover.jpg'

    images:
      - url: 'assets/brands-to-love/Levis.png'
        title: "Levi's"
        caption: "
          <h2>Levi's</h2>
          <p>Born in 1853 in San Francisco, this iconic name is loved for its head-to-toe denim range, designed for the long haul.</p>
          <a href='http://www.theiconic.com.au/levis/' class='button outline' target='_blank'>SHOP NOW</a>
        "
      - url: 'assets/brands-to-love/Nobody-Jeans.png'
        title: 'Nobody Denim'
        caption: '
          <h2>Nobody Denim</h2>
          <p>Starting from the backstreets of Melbourne, the premium brand’s jeans, denim shorts and skirts are highly in demand.</p>
          <a href="http://www.theiconic.com.au/nobody-dnm/" class="button outline" target="_blank">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Ziggy.png'
        title: 'Ziggy'
        caption: '
          <h2>Ziggy</h2>
          <p>The label offers denim plus street style dresses and staples inspired by Melbourne’s creative, art-infused alleyways.</p>
          <a href="http://www.theiconic.com.au/ziggy/" class="button outline" target="_blank">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Mavi-Jeans.png'
        title: 'Mavi Jeans'
        caption: '
          <h2>Mavi Jeans</h2>
          <p>Founded in Istanbul, the brand’s philosophy stays true to creating the perfect fits for women around the world.</p>
          <a href="http://www.theiconic.com.au/mavi/" class="button outline" target="_blank">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Jack-Jones.png'
        title: 'Jack & Jones'
        caption: '
          <h2>Jack & Jones</h2>
          <p>One of Europe’s leading names for quality jeans, apparel and street shoes with an urban edge.</p>
          <a href="http://www.theiconic.com.au/jack-jones/" class="button outline" target="_blank">SHOP NOW</a>
        '
      - url: 'assets/brands-to-love/Gstar-raw.png'
        title: 'G-Star Raw'
        caption: '
          <h2>G-Star Raw</h2>
          <p>Pioneering denim since 1989, the brand is known for its cutting-edge style and no-fuss quality jeans and apparel.</p>
          <a href="http://www.theiconic.com.au/g-starraw/" class="button outline" target="_blank">SHOP NOW</a>
        '

    layout:
      type: custom

---

<figure class="cover-area image" style="background-image: url({{ cover.url }})">
  <header>
    <h1 class="title">Brands To <b>Love</b></h1>
    <p class="summary">{{ summary }}</p>
  </header>
</figure>

<div class="content">
  <div class="body">
    <ul id="flip-cards" class="no-gutter">
      {{#images}}{{^layout}}
      <li class="event col half v-half" ontouchstart="this.classList.toggle('hover')" data-track="hotspot:click">
        <div href="#" class="flipper">
          <div class="image" style='background-image: url({{ url }})'></div>
          <div class="info"><div class="wrapper">{{{ caption }}}</div></div>
        </div>
      </li>
      {{/layout}}{{/images}}
    </ul>
  </div>
</div>
