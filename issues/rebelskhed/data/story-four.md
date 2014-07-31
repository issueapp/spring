---

    category: "#Spotted"
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
    <span class="category">Social</span>
    <h1 class="title">#AJL Spotted</h1>
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