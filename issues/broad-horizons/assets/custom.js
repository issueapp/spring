var setupGeoLink = function() {
  $(document).on('click', 'a[href|="geo:"]', function(e) {
    e.preventDefault();

    var geo = e.currentTarget.href.match(/(-?\d+.?\d*),(-?\d+.?\d*)/);
    var latitude = geo[1];
    var longitude = geo[2]
    if (!latitude || ! longitude) {
      throw 'Latitude and/or longitude not found';
    }
    var label = e.currentTarget.href.match(/label=([^&;]+)/);
    if (label) label = decodeURIComponent(label[1]);
    var zoom = e.currentTarget.href.match(/zoom=([^&;])/);
    if (zoom) zoom = zoom[1];

    var mapContainerId = ('map'+latitude+'__'+longitude).replace(/\./g, '_');
    var mapContainerStyle = 'width:'+Math.max(document.documentElement.clientWidth, window.innerWidth || 0)+'px;'+
                            'height:'+Math.max(document.documentElement.clientHeight, window.innerHeight || 0)+'px;'+
                            'position: absolute; top: 0; left: 0';
    var $mapContainer = $('#'+mapContainerId);
    if ($mapContainer.length < 1) {
      $mapContainer = $('<div id="'+mapContainerId+'" class="map" style="' + mapContainerStyle + '"></div>');
      $(document.body).append($mapContainer);
    }
    $mapContainer.show();
    var $closeButton = $('#close-map');
    if ($closeButton.length < 1) {
      $closeButton = $('<a id="close-map" style="position: absolute; bottom: 20px; right: 15px" href="#" onclick="$('+"'.map'"+').hide(); $(this).hide()">close</a>');
      $(document.body).append($closeButton);
    }
    $closeButton.show();

    var center = new google.maps.LatLng(latitude, longitude);
    var marker = new google.maps.Marker({
      position: center,
      animation: google.maps.Animation.DROP
    });
    var map = new google.maps.Map(
      $mapContainer[0],
      {
        zoom: (zoom || 7),
        center: center
      }
    );

    marker.setMap(map);

    if (label) {
      var info = new google.maps.InfoWindow({
        content: label
      });

      info.open(map, marker);

      google.maps.event.addListener(marker, 'click', function() {
        info.open(map, marker);
      });
    }
  });
};

$(function() {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyCV5jQkaOQYZO9szxfYYyb06lAvihOjbMw&callback=setupGeoLink';
  document.body.appendChild(script);
});
