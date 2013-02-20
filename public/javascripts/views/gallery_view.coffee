class App.GalleryView extends App.SwipeView
  el: '#gallery .swipe-paging'

  events:
    'touchend span.prev': 'prev'
    'touchend span.next': 'next'

  template: Mustache.compile(
    '
    <header class="toolbar">
      <a class="back">back</a>
      <div class="title"><span class="dropdown"></span></div>
      <div class="actions"><a class="share"></a></a>
    </header>
    <div class="swipe-paging">
      {{#collection}}
      <div class="page image">
        <img src="{{source}}">
        <footer>
          <h3>name of the photo</h3>
          <p class="description">description</p>
          <span class="prev">prev</span>
          <span class="next">next</span>
          <nav class="paginate"></nav>
        </footer>
      </div>
      {{/collection}}
    </div>
    <div class="overlay"></div>
    '
  )

  initialize: (data)->
    # inherit swipe events
    swipe_events = _.result(@constructor.__super__, 'events')
    _.extend(@constructor.prototype.events, swipe_events)

    @galleryWrapper = $('#gallery')

    $('#gallery a.back').live 'click', (e)=>
      this.close()
      false

  resetAttr: ->
    @currentPage = this.$('.current').eq(0)
    @pageTracker = @galleryWrapper.find('header .title span')
    @currentPageCount = 1

    @offset = @currentIndex = @startClientX = @currentClientX = 0

    if @currentPage.length == 0
      @currentPage = this.$el.children(":not(.padding)").first().addClass('current')

    if expandMenu = $('body.expand-menu')[0]
      @viewport = expandMenu.offsetWidth
    else
      @viewport = @el.parentNode.offsetWidth

    @bufferSize = @images.collection.length
    @pageTracker.html(@currentPageCount + ' of ' + @bufferSize)

  render: ->
    @images = { 'collection': [] }
    $('.page.current .gallery').find('a').forEach (item)=>
      @images.collection.push { 'source': $(item).attr('href') }

    @galleryWrapper.html @template(@images)
    this.setElement('#gallery .swipe-paging')
    this.resetAttr()

    this.$el.css('height', window.innerHeight)
    this.$el.find('.page:nth-child(1)').addClass('current')

  next: -> this.moveRight()
  prev: -> this.moveLeft()

  close: ->
    this.$el.find('img').forEach (item)->
      $(item).attr('src', '/images/blank.gif')
    @galleryWrapper.html('')

  moveRight: ->
    @currentPageCount += 1 if @currentPageCount < @bufferSize
    this.slideTo("next")
    this.updatePageTracker()

  moveLeft: ->
    @currentPageCount -= 1 if @currentPageCount > 1
    this.slideTo("prev")
    this.updatePageTracker()

  updatePageTracker: ->
    setTimeout =>
      @pageTracker.html(@currentPageCount + ' of ' + @bufferSize)
    , 400
