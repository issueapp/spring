---

    title: Map
    category: Where Am I
    
    thumb_url: assets/Sweet-Chargrilled-Peaches-Sourdough.jpg
    cover_url: assets/Sweet-Chargrilled-Peaches-Sourdough.jpg
    
      

---

<div id="map-canvas"/>


<script type="text/javascript">
 function initialize() {
   var mapOptions = {
     center: new google.maps.LatLng(-34.397, 150.644),
     zoom: 8
   };
   var map = new google.maps.Map(document.getElementById("map-canvas"),
       mapOptions);
 }
 google.maps.event.addDomListener(window, 'load', initialize);
</script>