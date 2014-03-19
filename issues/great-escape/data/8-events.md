---

    title: Events Calendar 
    category: 
    description: 

    thumb_url: assets/toc/calendar.jpg

    layout:
      type: custom
      image_style: background
      content_align: left

    links:
      - title: Melbourne Food and Wine Festival 
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m03-02.jpg
        summary: Indulge your taste buds with a world class program of over 300 culinary events filling Melbourne’s maze of hidden laneways, as well spectacular regional Victoria.
        url: http://www.melbournefoodandwine.com.au/

      - title: Sculptures by the Sea, Cottesloe 
        summary: The stunning Cottesloe Beach will be transformed into a spectacular sculpture park, featuring more than 70 artists from Australia and across the world.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m03-07.jpg
        url: http://www.sculpturebythesea.com/exhibitions/cottesloe.aspx

      - title: Opera on Sydney Harbour
        summary: Indulge your love of opera performed on a shimmering stage on the waters of Sydney Harbour.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m04-01.jpg 
        url: http://opera.org.au/whatson/events/operaonsydneyharbour

      - title: BMW Sydney Carnival 
        summary: Experience the thrill of world-class racing, stunning fashion and fantastic entertainment at the Sydney Carnival.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m04-07.jpg 
        url: http://www.sydney.com/events/the-bmw-sydney-carnival

      - title: Sydney Royal Easter Show
        summary: Enjoy Australia’s agricultural heritage with great food, wine and carnival rides for the whole family.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/2013/lrg/m03-01.jpg 
        url: http://www.eastershow.com.au/

      - title: The Horizontal Falls
        summary: Witness a spectacular phenomena of the Kimberley coast in Western Australia as seawater rushes through the narrow gorges.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m03-10.jpg 
        url: http://www.australia.com/nationallandscapes/the-kimberley.aspx?pagenotfound=/campaigns/nationallandscapes/thekimberley.htm 

      - title: Aussie Wine Month
        summary: Taste the quality and diversity of Australian wines from over 60 designated wine regions.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m04-02.jpg 
        url: http://www.wineaustralia.net.au/en/aussie-wine-month-2014.aspx 

      - title: Rosemount Australian Fashion Week, Sydney 
        summary: Get a sneak peek of the next spring/summer trends and be amongst Australia’s style-setters and celebrities before you claim your reserved seat next to the runaway.
        image_url: http://wac.3e65.edgecastcdn.net/803E65/sydney/cdnzzz/560-274-aHR0cDovL2NvbmNyZXRlcGxheWdyb3VuZC5jb20uYXUvX3NuYWNrcy93cC1jb250ZW50L3VwbG9hZHMvMjAxMS8wNC81MTQyMDAtcmFmdy0yMDEwLWdhcnktYmlnZW5pLmpwZw==.jpg 
        url: http://sydney.concreteplayground.com.au/event/18754/rosemount-australian-fashion-week.htm 

      - title: Vivid Sydney 
        summary: Delight in a festival which transforms Sydney into a spectacular canvas of light and music.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m05-06.jpg 
        url: http://www.vividsydney.com/ 

---
<style>
  #event-cards {
    margin: 0;
    padding: 0;
    height: 100%;
    list-style: none;

    -webkit-perspective: 1000;
    -moz-perspective: 1000;
    -o-perspective: 1000;
    perspective: 1000;
  }

  #event-cards li {
    height: 33.3%;
    width: 33.3%;
    background-size: cover;
  }

  #event-cards .flipper {
    position: relative;
    width: 100%;
    height: 100%;

    -webkit-transition: 0.6s;
    -moz-transition: 0.6s;
    -o-transition: 0.6s;
    transition: 0.6s;

    -webkit-transform-style: preserve-3d;
    -moz-transform-style: preserve-3d;
    -o-transform-style: preserve-3d;
    transform-style: preserve-3d;
  }

	#event-cards li:hover .flipper,
  #event-cards li.hover .flipper {
    -webkit-transform: rotateY(180deg);
    -moz-transform: rotateY(180deg);
    -o-transform: rotateY(180deg);
    transform: rotateY(180deg);
	}

  #event-cards li .image {
  	position: absolute;
  	top: 0;
  	left: 0;
  }

  /* front pane, placed above back */
  #event-cards li .image {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 2;
    background-position: center;
    background-size: cover;

    -webkit-backface-visibility: hidden;
    -moz-backface-visibility: hidden;
    -o-backface-visibility: hidden;
    backface-visibility: hidden;
  }

  /* back, initially hidden pane */
  #event-cards li .info {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 2;
    overflow: auto;
    padding: 20px;
    background: #fff;
    color: #333;
    font-size: 14px;

    -webkit-transform: rotateY(180deg);
    -moz-transform: rotateY(180deg);
    -o-transform: rotateY(180deg);
    transform: rotateY(180deg);

    -webkit-backface-visibility: hidden;
    -moz-backface-visibility: hidden;
    -o-backface-visibility: hidden;
    backface-visibility: hidden;
  }

  #event-month-list {
    float: left;
    width: 31%;
    text-align: left;
    font-weight: normal;
    font-family: "EB Garamond";
  }

  #event-month-list .event-title {
    margin: 20px 0;
    text-align: center;
    letter-spacing: 2px;
    font-weight: normal;
    font-size: 24px;
  }

  #event-month-list .event-month {
    margin: 15px 0;
    padding: 0;
    border-bottom: 1px solid #111;
    font-weight: normal;
    font-size: 18px;
    font-family: "EB Garamond";
  }

  #event-month-list .event-list {
    margin: 0;
    padding: 0;
  }

  #event-month-list .event-list h3 {
    margin: 0;
    font-weight: normal;
    font-family: "EB Garamond";
  }

  #event-month-list .event-list li {
    margin-bottom: 1em;
    text-align: left;
  }

  #event-month-list address {
    color: #404040;
  }

  #event-month-list date {
    float: right;
    color: #404040;
  }
</style>

<div class="cover col x8">
  <ul id="event-cards" class="no-gutter">
  {{#links}}
    <li class="event col x4" ontouchstart="this.classList.toggle('hover')" data-track="hotspot:click" title="{{ title}} ">
      <div href="{{ url }}" class="flipper">
        <div class="image" style='background-image: url({{ image_url }})'></div>
        <div class="info">
          <h3>{{ title }}</h3>
          <p>{{ summary }}</p>
          <a href="{{ url }}"  data-track="link:click" title="{{ url }} " target="_blank">Learn more</a>
        </div>
      </div>
    </li>
  {{/links}}
  </ul>
</div>

<div id="event-month-list" class="content col x4">
  <h1 class="event-title">{{ title }}</h1>
  <h2 class="event-month">MARCH-APRIL</h2>
  <ol class="event-list">
    <li>
      <h3>Melbourne Food and Wine Festival </h3>
      <date>28 Feb-16 Mar</date>
      <address>Melbourne, VIC</address>
    </li>

    <li>
      <h3>Sculptures by the Sea</h3>
      <date>7-24 Mar</date>
      <address>Cottlesloe Beach, WA</address>
    </li>

    <li>
      <h3>Opera on Sydney Harbour</h3>
      <date>21 Mar-12 Apr</date>
      <address>Sydney, NSW</address>
    </li>

    <li>
      <h3>BMW Sydney Carnival </h3>
      <date>22 Mar-26 Apr</date>
      <address>Sydney, NSW</address>
    </li>
  </ol>

  <h2 class="event-month">APRIL-MAY</h2>
  <ol class="event-list" start="5">
    <li>
      <h3>Sydney Royal Easter Show</h3>
      <date>10 - 23 Apr</date>
      <address>Perth, WA</address>
    </li>
    <li>
      <h3>The Horizontal Falls </h3>
      <date>Mar - May</date>
      <address>Talbot Bay, WA</address>
    </li>
    <li>
      <h3>Aussie Wine Month</h3>
      <date>1-30 Apr</date>
      <address>Australia-wide</address>
    </li>
    <li>
      <h3>Rosemount Australian Fashion Week, Sydney </h3>
      <date>2-6 May</date>
      <address>Circular Quay, Sydney NSW</address>
    </li>
    <li>
      <h3>Vivid Sydney</h3>
      <date>May</date>
      <address>Sydney, NSW</address>
    </li>
  </ol>
</div>

