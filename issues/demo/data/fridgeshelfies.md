---

    category: "#HashTag"
    title: "#Fridge Shelfies"
    
    thumb_url: http://media-cache-ak0.pinimg.com/236x/02/46/91/024691df69af6a545eb7d5060ac7e87c.jpg
  
    images:
  
      - title: Box lay 
        url: http://media-cache-ec0.pinimg.com/736x/b1/4c/1a/b14c1a4c0e0d17924704cf933b6d6583.jpg
      
      - title: Box
        url: http://media-cache-ak0.pinimg.com/736x/b7/ed/a8/b7eda8ca023e3a320e2d7d78883f3787.jpg
        
      - title: couch 
        url: http://media-cache-cd0.pinimg.com/736x/6d/d0/ca/6dd0ca6d4e3d8af460d896433464a1ac.jpg
      
      - title: pose 
        url: http://media-cache-ak0.pinimg.com/236x/02/46/91/024691df69af6a545eb7d5060ac7e87c.jpg
      
      - title: back 
        url: http://media-cache-ak0.pinimg.com/236x/16/76/37/1676371e5b71317a7779782cc8ffa4a0.jpg
      
      - title: lay down 
        url: http://media-cache-ec0.pinimg.com/236x/13/9a/ec/139aec0681356f3feac7cfb0e5b5f74b.jpg

    layout:
      nav: true
      type: custom

---
<header>
<h1 class="title">#Fridge Shelfies</h1>
</header>

<div class="content">
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