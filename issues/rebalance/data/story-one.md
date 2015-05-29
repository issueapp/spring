---

    title: Gut Instinct
    summary:
      'Animated graphic + Custom page'

    cover_url: 'assets/story-one/gut.png'
    thumb_url: 'assets/story-one/gut.png'

    custom_html: true

    layout:
      type: three-column
      image_style: fit
      image_align: right
      content_valign: middle

---

<figure class="cover-area image" style="background-image: url({{ cover.url }})"></figure>

<div class="content">
  <header>
    <div class="wrapper">
      <h1 class="title">{{ title }}</h1>
      <h3 class="subtitle">{{ summary }}</h3>
    </div>
  </header>

  <a class="button outline small" href="#slideOne" data-app-view="layer">View Item 3</a>

  <article id="slideOne" class="page stack">
    <div class="content">
      <h2>Lorem ipsum dolor</h2>
      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quasi fugit quae, reiciendis ut amet voluptatem, vero temporibus sequi fuga quia provident. Atque error rerum, maxime doloribus laboriosam! Quo, quaerat. Deserunt!</p>
      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quasi fugit quae, reiciendis ut amet voluptatem, vero temporibus sequi fuga quia provident. Atque error rerum, maxime doloribus laboriosam! Quo, quaerat. Deserunt!</p>
      <footer>
        <a href="#slideOne" class="button outline small close action">Continue</a>
      </footer>
    </div>
  </article>
</div>
