---

    category: "Moments"
    title: "#AcademyMoments"
    
    thumb_url: assets/moments/3.jpg
  
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
      nav: true
      type: custom

---

<div class="content">
  <header>
    <span class="category">Social</span>
    <h1 class="title">#AcademyMoments</h1>
  </header>
  
  <ul clas="polaroids">
  {{#images}}
    <li class="polaroid-wrap"><a class="">
      <figure class="polaroid">
        <img src="{{ url}}" alt=" {{ title }}" title=" {{ title }}">
        <figcaption>{{ caption }}</figcaption>
      </figure>
    </a>
  {{/images}}
  </ul>
</div>