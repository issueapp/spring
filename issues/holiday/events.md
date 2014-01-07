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
  #event-title {
    font-size: 24px;
    letter-spacing: 2px;
    text-align: center;
    font-weight: normal;
    margin: 20px 0;
  }
  #event-cards {
  	perspective: 1000;
    
    height: 100%;
    list-style: none;
    padding: 0; margin: 0;
  }
  
  #event-cards li {
    height: 33.3%;
    width: 33.3%;
    background:size: cover;
  }
  
  .flipper {
    width: 100%;
    height: 100%;
    -webkit-transition: 0.6s;
    -webkit-transform-style: preserve-3d;
    -moz-transition: 0.6s;
    -moz-transform-style: preserve-3d;
    transition: 0.6s;
    transform-style: preserve-3d;
    position: relative;
  }
  
	#event-cards li:hover .flipper,
  #event-cards li.hover .flipper {
		transform: rotateY(180deg);
		-webkit-transform: rotateY(180deg);
	}
  
  #event-cards li .image {
  	position: absolute;
  	top: 0;
  	left: 0;
  }
  
  /* front pane, placed above back */
  #event-cards li .image {
    background-position: center;
    background:size: cover;
    
  	-webkit-backface-visibility: hidden;
    
  	z-index: 2;
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
  }

  /* back, initially hidden pane */
  #event-cards li .info {
  	-webkit-backface-visibility: hidden;
    
    background: #fff;
    color: #333;
    font-size: 14px;
    padding: 20px;
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
		-webkit-transform: rotateY(180deg);
  }
  
  #event-cards li a {
    
  }
  
  #event-month-list {
    font-family: "EB Garamond";
    text-align: left;
    font-weight: normal;
    width: 31%;
    float: left;
  }
  
  .event-month {
    font-family: "EB Garamond";
    font-weight: normal;
    
    padding: 0;
    font-size: 18px;
    border-bottom: 1px solid #111;
    margin: 15px 0;
  }
  
  .event-list {
    
    margin: 0;
    padding: 0;
  }
  .event-list h3 {
    font-family: "EB Garamond";
    
    margin: 0;
    font-weight: normal;
  }
  .event-list li {
    text-align: left;
    margin-bottom: 1em;
  }
  
  address {
    color: #404040;
  }
  
  date {
    color: #404040;
    float: right;
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
  <h1 id="event-title">{{ title }}</h1>
  
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

