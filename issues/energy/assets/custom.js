var setupGeoLink = function() {
  console.log('map is ready');
};

$(function() {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyCV5jQkaOQYZO9szxfYYyb06lAvihOjbMw&callback=setupGeoLink';
  document.body.appendChild(script);

  function resizeBgVideo() {
    var video        = $('.cover-area.video video');
    var imageWidth   = 1922;
    var imageHeight  = 1080;
    var headerHeight = video.parent().height();


    if (video.length == 0)
      return;

    // video.playbackRate = 1.5

    videoWidth  = video.parent().width();
    videoHeight = videoWidth * imageHeight / imageWidth;

    if (videoHeight <= headerHeight) {
      videoHeight = headerHeight;
      videoWidth  = headerHeight * imageWidth / imageHeight;
    }

    video[0].style.width  = parseInt(videoWidth) + 'px';
    video[0].style.height = parseInt(videoHeight) + 'px';
  }
  
  resizeBgVideo();
  
  $('.infographic .tabs a').live('click', function() {
    var target =  this.getAttribute('href')
    $('.info-box').hide()
    
    $(target).fadeIn()
    
    return false
  })
  
});
