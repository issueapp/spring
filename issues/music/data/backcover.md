---

    nav: false

    image_url: assets/6-behind-the-scene/p1.jpg
    layout:
      image_style: background
      content_style: transparent
      content_height: full

---
<style>

  article.page[data-page=backcover] {
    -webkit-backface-visibility: hidden;
    -webkit-perspective: 1000;
  }

  article.page[data-page="backcover"] .content {
    margin: 0;
    max-height: initial;
    width: 100%;
    height: 100%;
  }
  
  article.page[data-page="backcover"] .cover-area {
    background-position: top;
  }

  article.page[data-page="backcover"] #image {
    
    position: absolute;
    bottom: 10%;
    max-width: initial;
    max-height: initial;
    width: 300px;
  }

  @media only screen and (min-width: 768px) {
    article.page[data-page="backcover"] #image {
      left: 50%;
      margin-left: -300px;
      width: 640px;
    }
  }
</style>


<a href="http://minkpink.com/" title="Visit Minkpink" target="_blank">
  <img id="image" src="assets/6-behind-the-scene/p1-1.png" alt="">
</a>