
class MapView extends Backbone.View
  className: "map-container"

  events: {
    "click .close-map": "close"
  }

  # Location object
  location: { name: "Sydney australia", longitude: 0, latitude: 0 }

  target: null

  # Pass location object and target element
  initialize: (data)->

    # Rendering target, defaults to window
    @target = data.target || window
    @location = data.location
    @zoom = 7
    @closeBtn = $('<a class="close-map" href="#"><i class="icon-cancel"></i></a>')

  render: ->
    console.log("Render map view for", @location, this.$el.html())

    @el.id = this.cid

    # Setup google map
    unless @map
      this.buildMap(@location)
      this.$el.append(@closeBtn)
    else
      App.loading(false)

    # Renders map elements
    this.$el.css(
      position: "absolute"
      zIndex: 1
      top: 0,
      left: 0,
      right: 0,
      bottom: 0
    )

    this.$el.show()
    @closeBtn.show()

    console.log("view element", @el)
    if @target == window
      document.body.appendChild(@el)
    else
      $(@target).append(@el)

    # Force google map to resize, it needs to be inserted to dom to have layout
    google.maps.event.trigger(@map, "resize");

  # Build instance of google map
  buildMap: (location)->
    console.log("Build map for", location.latitude, location.longitude)

    place = new google.maps.LatLng(parseFloat(location.latitude), parseFloat(location.longitude))
    @map = new google.maps.Map(@el, zoom: 7, center: place)
    marker = new google.maps.Marker(
      position: place
      animation: google.maps.Animation.DROP
      map: @map
    )

    if location.name
      info = new google.maps.InfoWindow(content: location.name)
      info.open @map, marker

      google.maps.event.addListener marker, 'click', => info.open(@map, marker)
      google.maps.event.addListener @map, "tilesloaded", => App.loading(false)
    @map

  # close map view
  close: ->
    @closeBtn.hide()
    this.$el.hide()
    false

@MapView = MapView

