---
    category: Info
    title: What is Activia
    summary: Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quasi fugit quae, reiciendis ut amet voluptatem, vero temporibus sequi fuga quia provident. Atque error rerum, maxime doloribus laboriosam! Quo, quaerat. Deserunt!

    thumb_url: 'assets/what-is-activia/1.jpg'
    cover_url: 'assets/what-is-activia/1.jpg'

    images:
      - title: Image
        url: assets/what-is-activia/1.jpg

      - title: Image
        url: assets/what-is-activia/2.jpg

      - title: Image
        url: assets/what-is-activia/3.jpg

      - title: Image
        url: assets/what-is-activia/4.jpg

      - title: Image
        url: assets/what-is-activia/5.jpg

      - title: Image
        url: assets/what-is-activia/6.jpg

      - title: Image
        url: assets/what-is-activia/7.jpg

      - title: Image
        url: assets/what-is-activia/8.jpg

      - title: Image
        url: assets/what-is-activia/9.jpg

      - title: Yoghurt
        url: assets/yoghurt.png
        layout: true

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
    {{^layout}}
    <li class="polaroid-wrap">
      <figure class="polaroid">
        <img src="{{ url }}" alt="{{ title }}" title="{{ title }}">
      </figure>
    </li>
    {{/layout}}
  {{/images}}
  </ul>
</div>

<div class="content col x4">
  <header>
    <img src="assets/yoghurt.png" data-media-id="images:10" data-original>
    <h1 class="title">Restore Your Balance</h1>
  </header>
  <div class="body">
    <p>Pure by Activia Greek Style Yoghurt contains Bifidus ActiRegularis®, a probiotic bacteria which is scientifically proven for its ability to survive in the digestive system and help reduce gastrointestinal discomfort associated with gas, like bloating and rumbling.</p>
    <p>With a deliciously creamy taste and texture, Pure by Activia yoghurt is made from fresh cow’s milk sourced from local Australian farmers. The milk is free from genetically modified organism (GMO) to make it 100% pure natural Australian milk.Free from gelatin, artificial thickeners and colours, it contains no added sugar.</p>
    <p>Consuming probiotic rich foods such as Pure by Activia yoghurt on a regular basis is a great way to help give your digestive system the support it needs to function properly – and keep you feeling good.</p>
  </div>
</div>
