---

    title: Holiday style
    category: Destination
    description: Italia Riveria

    layout:
      type: custom
      image_style: background
      content_align: left

    links:
      - title: Magic Millions Raceday
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m01-06.jpg
        summary: Enjoy the racing and glamour of one of Australia’s biggest Carnival thoroughbred events held on the vibrant Gold Coast.
        url: http://www.magicmillions.com.au/carnivals/

      - title: Australian Open – The Grand Slam of Asia-Pacific
        summary: See the greatest tennis players in the world compete for this coveted grand slam trophy in the vibrant cosmopolitan city of Melbourne.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m01-02.jpg
        url: http://www.australianopen.com/

      - title: Sydney Festival
        summary: See the city come alive with a kaleidoscopic program of theatre, music, dance and visual arts, free outdoor concerts and pop-up bars.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m01-04.jpg
        url: http://www.sydneyfestival.org.au/

      - title: Australia Day
        summary: Celebrate Australia’s unique cultural diversity with family and friends and reflect on our nation’s heritage.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m01-07.jpg
        url: http://www.australiaday.org.au/

      - title: Perth International Arts Festival
        summary: Indulge your senses with symphonies, cutting-edge plays and art presented both indoors and outdoors in Perth.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m02-05.jpg
        url: http://www.perthfestival.com.au/

      - title: The Spirit Festival
        summary: Join this vibrant celebration of traditional and contemporary Aboriginal and Torres Strait Islander culture, art, dance and music.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m02-02.jpg
        url: http://www.thespiritfestival.com/

      - title: Australian Sand Sculpting Championships
        summary: Delight in the beautiful and bizarre sand sculptures built on Surfers Paradise Beach.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m02-03.jpg
        url: http://www.sandstormevents.net/major-events-2/aust-sand-sculpting-championships/

      - title: Chinese New Year
        summary: Celebrate good fortune and prosperity with the most important celebration in the Chinese calendar.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m02-04.jpg
        url: http://www.chinesenewyear.com.au/

      - title: Turtle nesting
        summary: See six of the world’s seven species of marine turtle come ashore from Ningaloo Reef to nest on the West Coast of Australia.
        image_url: http://www.australia.com/campaigns/eventscalendar/data/images/lrg/m02-10.jpg
        url: http://www.australia.com/campaigns/nationallandscapes/NingalooSharkBay.htm

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
  <h2 class="event-month">Janurary</h2>
  <ol class="event-list">
    <li>
      <h3>Magic Millions Raceday</h3>
      <date>11 Jan</date>
      <address>Gold Coast, QLD</address>
    </li>

    <li>
      <h3>AustraLian Open</h3>
      <date>13 Jan</date>
      <address>Melbourne, VIC</address>
    </li>

    <li>
      <h3>Sydney Festival</h3>
      <date>9-26 Jan</date>
      <address>Sydney, NSW</address>
    </li>

    <li>
      <h3>Australia Day</h3>
      <date>26 Jan</date>
      <address>Nation Wide</address>
    </li>
  </ol>

  <h2 class="event-month">Feburary</h2>
  <ol class="event-list" start="5">
    <li>
      <h3>Pearth International Arts Festival</h3>
      <date>7 Feb - 1 Mar</date>
      <address>Perth, WA</address>
    </li>
    <li>
      <h3>The Spirit Festival</h3>
      <date>15-17 Jan</date>
      <address>Adelaide, SA</address>
    </li>
    <li>
      <h3>Sand Sculpting Championships</h3>
      <date>14-Feb-2Mar</date>
      <address>Melbourne, VIC</address>
    </li>
    <li>
      <h3>Chinese New Year</h3>
      <date>18-28 Jan</date>
      <address>Australia-wide</address>
    </li>
    <li>
      <h3>Turtle Nesting Season</h3>
      <date>Dec-April</date>
      <address>reat Barrier Reef, QLD</address>
    </li>
  </ol>
</div>

