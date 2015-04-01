class PageView extends Backbone.View
  el: 'article.page'

  # scroller
  width: 0
  offset: 0
  clientX: 0
  clientY: 0

  events:
    "click .video": "playVideo"
    "click .hotspot": "showHotspot"
    "click a[data-app-view=layer]" : "openLayer"

    "click a[href|='geo:']" : 'showMap'
    "click a[href]:not(.hotspot)" : "visit"

  initialize: (data)->
    @url = data.url
    @path = data.path
    @viewport = App.viewport

    @width = @viewport.width
    @container = $(window)

    theme = this.$el.data('theme')
    theme = 'black' if this.$el.hasClass('cover') # || typeof theme == "undefined"

    App.trigger('page:loaded', @path, path: @path, theme: theme)

    # @hotspot = new Hotspot(el: "##{@el.id} .hotspot") if @el && @el.parentNode

  # Scroller code
  onTouch: (e) ->
    e = e.touches[0] if e.touches

    return if e.button == 2

    @touched = true

    @clientX = e.clientX
    @clientY = e.clientY

    $(@el).removeClass('animate').addClass('swiping')

  onMove: (e)->
    return unless @touched

    e = e.touches[0] if e.touches
    deltaX = e.clientX - @clientX

    # console.log("Move/scroll", @width, @offset, deltaX, e)

    if this.isPaginated()
      # left edge
      return if @offset == 0 && deltaX > 0

      # right edge
      return if Math.abs(@offset) == (@width - @viewport.width) && deltaX < 0

      this.updatePos(@offset + deltaX)

      false

  onTouchEnd: (e) ->
    @touched = false

    return unless this.isPaginated()
    e = e.changedTouches[0] if e.changedTouches

    deltaX = e.clientX - @clientX

    # Stop swiping and animate the left go.
    $(@el).addClass('animate').removeClass('swiping')

    # Snap to the left
    if @offset == 0 && deltaX > 0
      return this.updatePos(0)

    # Snap to right edge
    if Math.abs(@offset) == (@width - @viewport.width) && deltaX < 0
      return this.updatePos(@offset)

    # Ingore small movement
    if Math.abs(deltaX) < 50
      return this.updatePos(@offset)

    # go next
    if deltaX < 50
      this.next()
    else
      this.prev()

  loadPage: (element)->
    # @hotspot.undelegateEvents() if @hotspot
    #
    # @hotspot = new Hotspot(el: "##{@el.id} .hotspot") if @el

    this.setElement(element)

  updatePos: (offset)->
    has3D = 'WebKitCSSMatrix' of window && 'm11' of new WebKitCSSMatrix()
    if has3D
      @el.style.webkitTransform = 'translate3d(' + offset + 'px, 0, 0)'
    else
      this.$el.css('transform', 'translate3d(' + offset + 'px, 0, 0)')
    # @el.style.webkitTransform = 'translate3d(' + offset + 'px, 0, 0)'

  showMap: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()

    geo = e.currentTarget.href.match(/(-?\d+.?\d*),(-?\d+.?\d*)/)
    latitude = geo[1]
    longitude = geo[2]
    if !latitude or !longitude
      throw 'Latitude and/or longitude not found'

    label = e.currentTarget.href.match(/label=([^&;]+)/)
    if label
      label = decodeURIComponent(label[1])

    zoom = e.currentTarget.href.match(/zoom=([^&;])/)
    if zoom
      zoom = zoom[1]

    mapContainerId = "map#{latitude}__#{longitude}".replace(/\./g, '_')
    mapContainerStyle = 'width:' + Math.max(document.documentElement.clientWidth, window.innerWidth or 0) + 'px;' + 'height:' + Math.max(document.documentElement.clientHeight, window.innerHeight or 0) + 'px;' + 'position: absolute; top: 0; left: 0'
    $mapContainer = $('#' + mapContainerId)
    if $mapContainer.length < 1
      $mapContainer = $('<div id="' + mapContainerId + '" class="map" style="' + mapContainerStyle + '"></div>')
      $(document.body).append $mapContainer
    $mapContainer.show()

    $closeButton = $('#close-map')
    if $closeButton.length < 1
      $closeButton = $('<a id="close-map" style="width: 50px; height: 50px; position: absolute; bottom: 0px; right: 50px; text-align: center;" href="#" onclick="$(' + '\'.map\'' + ').hide(); $(this).hide(); return false;"><i class="icon-cancel" style="font-size: 28px; line-height: 50px;color: #303030;"></i></a>')
      $(document.body).append $closeButton
    $closeButton.show()

    center = new (google.maps.LatLng)(latitude, longitude)
    marker = new (google.maps.Marker)(
      position: center
      animation: google.maps.Animation.DROP)
    map = new (google.maps.Map)($mapContainer[0],
      zoom: zoom or 7
      center: center)
    marker.setMap map
    if label
      info = new (google.maps.InfoWindow)(content: label)
      info.open map, marker
      google.maps.event.addListener marker, 'click', ->
        info.open map, marker

  visit: (e)->
    e.preventDefault()

    link = e.currentTarget
    $link = $(link)

    # Tracking
    track_click = ! $link.data("track") && ! $link.hasClass("browse")
    if track_click
      App.trigger("track", "click", link.href, linkTrackingAttributes(link))

    # google analytics custom campaign tracking params
    ga_params = "utm_source=issue.by&utm_campain=#{App.magazine.issue}&utm_content=#{App.currentPage.model.title}"
    link.href += if link.href.match(/\?/) then '&' else '?'
    link.href += ga_params

    if App.support.webview && !$link.data('app-view')
      App.trigger "open", link.href, linkTrackingAttributes(link)

    # external page
    else if link.href.match(/https?:\/\//)
      win = window.open(link.href, '_blank')
      win.focus()

    # Internal page is handling by magazine view
    else
      null

    true

  render: ->
    console.log("page:render", @path)

    if this.isPaginated()
      requestAnimationFrame => this.paginate()
    # this.updatePos(@offset) if @el

    # Disable video autoplay for small screen
    if window.screen.width <= 480
      this.$('video').each -> this.removeAttribute("autoplay")
        # console.log("video object", this)

    # Override
    # Display: none by magazine/cover, visiblity by swipeview.js
    @el.style.display = '' if @el.style.display == "none"
    @el.style.visibility = ''

    # make sure all pages start from the top position
    # console.log("Page Render: ", this.$el.parent())
    if document.getElementById('swipeview-slider') && this.$el.parent().scrollTop() != 0
      this.$el.parent().scrollTop(0)

    if this.el.parentNode
      this.el.parentNode.style.visibility = ''

  # set current page, track page view
  setActive: ->
    App.trigger('track', 'view', this.getTitle(), { page: this.getUrl() })

    return if this.isActive()

    currentPath = location.pathname.split("/").filter (path)-> path != ""
    currentPath = "/" + currentPath.join("/")

    # Set current
    App.currentPage = this

    # Update history pushState
    if !this.isEmbed() && this.getPath() != currentPath
      history.pushState(null, null, this.getPath())
      document.title = this.getTitle()

    $('article.page.current').removeClass('current')
    this.$el.addClass('current')

    # set autoplay
    this.$('video').each -> this.play() if @autoplay && @paused

    App.trigger("page:active", @path)

  getTheme: ->
    this.$el.data('theme') || "white"

  next: ->
    if this.isSwipe()
      $(@el).addClass('animate')
      this.updatePos(@offset -= @viewport.width)
    else
      window.scrollTo(@container.scrollLeft() + @viewport.width, 0)

  prev: ->
    if this.isSwipe()
      $(@el).addClass('animate')
      this.updatePos(@offset += @viewport.width)
    else
      window.scrollTo( Math.max(0, @container.scrollLeft() - @viewport.width) , 0)

  isEmbed: ->
    this.$el.hasClass('embed') || $(document.body).hasClass("editions-embed")

  canScroll: (dir)->
    if dir == 'prev' || dir == 'left'
      if this.isSwipe()
        @offset >= @viewport.width
      else
        @container.scrollLeft() >= @viewport.width
    else
      if this.isSwipe()
        Math.abs(@offset) < (@width - @viewport.width)
      else
        @container.scrollLeft() < this.$el.width() - @viewport.width

  # Multi media
  #
  playVideo: (e)->
    container = $(e.currentTarget)
    thumb = $(e.currentTarget).addClass('play').find('.thumbnail').hide()

    video = container.find('video')
    iframe = container.find('iframe')

    if video.length > 0

      video[0].play()

    else if iframe.length > 0

      iframe.attr('src', iframe.data('src')).show()

      notifyPlayer = (data)->
        iframe[0].contentWindow.postMessage(JSON.stringify(data), iframe.data('src').split('?')[0])

    App.trigger("track", "video:play", iframe.data('src'))

  showHotspot: (e)->
    hotspot = e.currentTarget
    model = App.pages[this.$el.attr("data-page")]

    @hotspot = new Hotspot(el: hotspot, model: model)
    @hotspot.render()

    false

  hideHotspot: (e)->
    if @hotspot
      @hotspot.hide()

  openLayer: (e)->
    link = $(e.currentTarget)

    App.pageOverlay(true)
    # App.lockScroll(true)

    layer = $(link.attr('href'))

    if layer.parent('[role=main]').length == 0
      $('[role=main]').append(layer)

    layer.show().removeClass('show').addClass('show')

    console.log("open layer", link, layer)

    false

  cleanup: ->
    this.el.style.visibility = 'hidden'
    this.hideHotspot()
    this.undelegateEvents()

  detectSwipe: ->
    return if App.support.webview

    if App.support.touch
      @events = _.extend({
        touchstart: "onTouch"
        touchmove: "onMove"
        touchend: "onTouchEnd"
      }, @events)
    else
      @events = _.extend({
        mousedown: "onTouch"
        mousemove: "onMove"
        mouseup: "onTouchEnd"
      }, @events)

  paginate: ->
    return unless this.isPaginated()

    # Observe page
    this.detectSwipe()

    this.delegateEvents()

    this.$el.removeClass('paginate')

    overflown = @el.scrollHeight > (@el.offsetHeight + 20)

    # detect if content overflows then
    if overflown

      console.log("paginate overflow content")

      this.$el.css('width', '')
      this.$el.addClass('paginate')

      setTimeout =>
        @width = Math.ceil( this.$el[0].scrollWidth / @viewport.width ) * @viewport.width
        this.$el.width(@width)

        # if this.isSwipe()
        #   $(@el).addClass('animate')
        #   this.updatePos(@offset -= @viewport.width)
        # else
        #   window.scrollTo( @container.scrollLeft() + @viewport.width, 0)

      , 200

  # Scroll end
  isSwipe: ->
    $('#swipeview-slider').length > 0

  isPaginated: ->
    this.$el.hasClass('paginate') && App.viewport.width > 480

  trackAttributes: ->
   {
     page: @url,
     title: this.$('.title').text(),
     page_id: this.$el.attr("data-page-id"),
     author: this.$el.attr("data-author")
   }

  isActive: ->
    this.$el.hasClass('current')

  isCover: ->
    this.$el.hasClass('cover')

  # TODO: Move to page model
  getTitle: ->
    if @model && @model.title
      @model.title
    else if @model && @model.parentTitle
      "#{@model.parentTitle} - #{@model.handle.split("/").slice(-1)[0]}"

  getPath: ->
    page = this.$el.data('page')
    parts = [
      $('[data-magazine]').data('magazine'),
      $('[data-issue]').data('issue')
    ]

    parts.push(page) unless page == "index"

    "/" + parts.join('/')

  getUrl: ->
    location.origin + this.getPath()

# Export to global
this.PageView = PageView
