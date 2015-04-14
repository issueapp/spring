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

  function updateStateGraph(target) {
    var windData = {
      nsw: 0.75,
      vic: 0.15,
      qld: 0.5,
      sa:  0.25,
      nt:  0.15,
      act: 0.25,
      wa:  0.15,
      tas:  0.05
    }
    var solarData = {
      nsw: 0,
      vic: 0,
      qld: 0,
      sa:  0.75,
      nt:  0.0,
      act: 0.0,
      wa:  0.5,
      tas:  0
    }
    
    if (target == "wind") {
      var data = windData
      var color = 'rgba(156, 215, 235, 1)'
    } else {
      var data = solarData
      var color = 'rgba(255, 130, 39, 1)'
    }
    
    for (var state in data) {
      var area = $('svg').find(".state."+state)
      var level = data[state]
      
      console.log("update", target, state, level)
      
      area.css({ opacity: level })
      area.attr('fill', color)
    }
  }

  updateStateGraph('wind')
  
  $('[data-page="turbine/3"].infographic .tabs a').live('click', function() {
    var page = $('[data-page="turbine/3"]')
    var target = this.getAttribute('href');
    var infos = $('.info-box').hide();
    var legends = $('.legend').hide()
    var header = page.find('.cover-area')
    var background = $(target).find('.background').attr('src')
    
    console.log(page)
    $(target).show();

    $(this).parent().find('.active').removeClass('active');
    $(this).addClass('active');
    header[0].style.backgroundImage = "url(" +background+ ")";
    
    if (target == "#infographic-wind") {
      updateStateGraph('wind')
      $('.legend.wind').show()
    } else {
      updateStateGraph('solar')
      $('.legend.solar').show()
    }
    return false;
  })
  
  $('[data-page="peoples-power/3"].infographic .tabs a').live('click', function() {
    var target = this.getAttribute('href');

    $('.info-box').hide();
    $(target).fadeIn();
    $(target).css('-webkit-transform', '')
    $(this).parent().find('.active').removeClass('active');
    $(this).addClass('active');

    return false;
  })

});
