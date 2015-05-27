---

    title: Story Three
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
  <ul>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
    <li><h3>Lorem ipsum</h3></li>
  </ul>
</div>
