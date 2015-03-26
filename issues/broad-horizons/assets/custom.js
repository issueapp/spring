var setupGeoLink = function() {
  console.log('map is ready');
};

$(function() {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyCV5jQkaOQYZO9szxfYYyb06lAvihOjbMw&callback=setupGeoLink';
  document.body.appendChild(script);
});
