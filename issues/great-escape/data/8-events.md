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
      - title: Rosemount Australian Fashion Week, Sydney
        summary: Get a sneak peek of the next spring/summer trends and be amongst Australia’s style-setters and celebrities before you claim your reserved seat next to the runaway.
        image_url: assets/8-events-calendar/rosemount.jpg
        url: http://sydney.concreteplayground.com.au/event/18754/rosemount-australian-fashion-week.htm

      - title: Noosa International Food & Wine Festival, Queensland
        summary: The festival features a line-up of more than 200 leading international and national chefs, iconic winemakers, high profile food and wine media, restaurateurs and serious food lovers, who converge on the seaside setting of Noosa to taste, talk and indulge over four days.
        image_url: assets/8-events-calendar/food-wine.jpg
        url: http://www.australia.com/explore/australian-events/food-wine-events.aspx

      - title: Vivid Sydney
        summary: Delight in a festival which transforms Sydney into a spectacular canvas of light and music.
        image_url: assets/8-events-calendar/vivid.jpg
        url: http://www.australia.com/explore/australian-events/major-events.aspx

      - title: Sydney Film Festival
        summary: One of the world's longest-running film festival. The 12-day festival screens more than 100 feature films, documentaries, short films and animation from more than 50 countries around the world and in almost as many languages.
        image_url: assets/8-events-calendar/sydney-film.jpg
        url: http://www.australia.com/explore/australian-events/art-events.aspx

      - title: Wildflowers in Bloom, Western Australia
        summary: You can see a multitude of native Australian wildflowers bloom in a vivid spectacle across the landscape. More than 12,000 species of wildflower can be seen blooming across Western Australia, including hundreds of species of delicate orchids
        image_url: assets/8-events-calendar/wildflowers.jpg
        url: http://www.australia.com/explore/australian-events/natural-events.aspx

      - title: City of Perth Winter Arts Season
        summary: The season combines a world-class selection of events and performances including theatre, film, comedy, opera, literature, dance, visual arts, poetry, cabaret and a range of free and family events. There are more than 150 events from more than 60 participating arts organisations.
        image_url: assets/8-events-calendar/winter-arts.jpg
        url: http://www.australia.com/explore/australian-events/art-events.aspx

      - title: Melbourne International Art Fair
        summary: Melbourne Art Fair is an exhibition of leading contemporary art, presented by more than 80 selected national and international galleries. The biennial event features paintings, sculpture, photography, installation and multi-media art works from over 900 artists.
        image_url: assets/8-events-calendar/melbourne-fair.jpg
        url: http://www.australia.com/explore/australian-events/art-events.aspx

      - title: Fireside Festival
        summary: The Fireside Festival is full of warming Southern Hemisphere winter experiences; from degustation dinners and wine tastings to performances. At various venues around Canberra, you can sip on exquisite cool climate wines, taste the delicacies from the region, meet passionate local artists, or just relax in front of an open fire.
        image_url: assets/8-events-calendar/canberra.jpg
        url: http://www.australia.com/explore/australian-events/art-events.aspx

      - title: Junction Arts Festival
        summary: Junction Arts Festival is an annual arts festival that fills up Launceston’s CBD with playful, contemporary art and performance that invite the audience to take part. Held over five days and nights, the festival features over 50 free unique audience experience. Events include live performance, theatre, visual and media art, literature, music and dance from leading local, national and international artists.
        image_url: assets/8-events-calendar/tasmania.jpg
        url: http://www.australia.com/explore/australian-events/art-events.aspx



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
    width: 33.33%;
    margin: 0;
    text-align: left;
    font-weight: normal;
    font-family: "EB Garamond";
    overflow: auto;
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
  <h2 class="event-month">MAY-JUNE</h2>
  <ol class="event-list">
    <li>
      <h3>Rosemount Australian Fashion Week</h3>
      <date>2 - 6 May</date>
      <address>SYDNEY, NSW</address>
    </li>

    <li>
      <h3>Noosa International Food & Wine Festival</h3>
      <date>May</date>
      <address>Noosa, QSLD</address>
    </li>

    <li>
      <h3>Vivid</h3>
      <date>June</date>
      <address>Sydney, NSW</address>
    </li>
    <li>
      <h3>Sydney Film Festival</h3>
      <date>June</date>
      <address>Sydney, NSW</address>
    </li>
    <li>
      <h3>Wildflowers in Bloom</h3>
      <date>June-Nov</date>
      <address>Western Australia</address>
    </li>
  </ol>

  <h2 class="event-month">JUNE-JULY</h2>
  <ol class="event-list" start="5">
    <li>
      <h3>City of Perth Winter Arts Season</h3>
      <date>June-August</date>
      <address>Perth, WA</address>
    </li>
    <li>
      <h3>Melbourne International Art Fair</h3>
      <date>August</date>
      <address>Melbourne, VIC</address>
    </li>
    <li>
      <h3>Fireside Festival</h3>
      <date>August</date>
      <address>Canberra, ACT</address>
    </li>
    <li>
      <h3>Junction Arts Festival</h3>
      <date>August</date>
      <address>Launceston, Tasmania</address>
    </li>
  </ol>
</div>

