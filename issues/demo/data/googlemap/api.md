---

  title: Googlemap API

---

<a href="/issue/demo/googlemap">Back</a> | <a href="/issue/demo/googlemap/embed">embed</a> | <a href="/issue/demo/googlemap/static">static</a>

<div id="map-canvas" class="map" style="width: 500px; height: 500px"></div>

Issue.

<!-- workaround for the first <script> tag gets rendered twice --><script>function bam(){}</script>

<script>
(function(){
  window.App || (window.App = {});

  App.initMap = function() {
    var center = new google.maps.LatLng(-33.886867, 151.207409);
    var marker = new google.maps.Marker({
      position: center,
      animation: google.maps.Animation.DROP
    });
    var map = new google.maps.Map(
      document.getElementById('map-canvas'),
      {
        zoom: 15,
        center: center,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        disableDefaultUI: true
      }
    );
    var info = new google.maps.InfoWindow({
      content: 'Hackerslab'
    });

    marker.setMap(map);
    google.maps.event.addListener(marker, 'click', function() {
      info.open(map, marker);
    });
  };

  function loadScript() {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyCV5jQkaOQYZO9szxfYYyb06lAvihOjbMw&callback=App.initMap';
    document.body.appendChild(script);
  }

  window.onload = loadScript;
})();
</script>
