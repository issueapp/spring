---

    category: "#Spotted"
    title: "#AJL Spotted"
    
    thumb_url: http://media-cache-ak0.pinimg.com/236x/02/46/91/024691df69af6a545eb7d5060ac7e87c.jpg
  
    images:
  
      - url: http://photos-c.ak.instagram.com/hphotos-ak-xpf1/10358327_1420621088203082_194095459_n.jpg
      
      - url: http://distilleryimage1.ak.instagram.com/365c671621d011e383d722000a1f99fc_7.jpg
        
      - url: http://photos-f.ak.instagram.com/hphotos-ak-xpa1/1921964_683496041701533_1362155555_n.jpg
      
      - url: http://photos-e.ak.instagram.com/hphotos-ak-xpa1/1921880_723072907723876_1124520623_n.jpg
      
      - url: http://distilleryimage10.ak.instagram.com/7192ca10a95611e397d812e01a16c456_8.jpg
      
      - url: http://photos-b.ak.instagram.com/hphotos-ak-xaf1/917136_792687944099185_275289068_n.jpg

      - url: http://photos-c.ak.instagram.com/hphotos-ak-xpa1/925564_713819045334546_311273338_n.jpg
      
      - url: http://photos-f.ak.instagram.com/hphotos-ak-xpf1/10414013_749312328452325_855998872_n.jpg

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