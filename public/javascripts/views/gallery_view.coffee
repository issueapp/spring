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
        </footer>
      </div>
      {{/collection}}
    </div>
    <nav class="paginate">
      {{#collection}}
        <span class="bullet"></span>
      {{/collection}}
    </nav>
    <div class="overlay"></div>
    '
  )

  initialize: (data)->
    # inherit swipe events from SwipeView
    swipe_events = _.result(@constructor.__super__, 'events')
    _.extend(@constructor.prototype.events, swipe_events)

    @galleryWrapper = $('#gallery')

    $('#gallery a.back').live 'click', (e)=>
      this.close()
      false

  # reset essential attributes for SwipeView, and update page number
  resetAttr: ->
    @currentPageCount = 1
    @currentPage = this.$('.current').eq(0)
    @pageTracker = @galleryWrapper.find('header .title span')
    @pagePagination = @galleryWrapper.find('nav.paginate')
    @offset = @currentIndex = @startClientX = @currentClientX = 0

    if @currentPage.length == 0
      @currentPage = this.$el.children(":not(.padding)").first().addClass('current')

    if expandMenu = $('body.expand-menu')[0]
      @viewport = expandMenu.offsetWidth
    else
      @viewport = @el.parentNode.offsetWidth

    # set buffer size to gallery image size to show all images in one go
    @bufferSize = @images.collection.length

    this.updatePageTracker()

  # render gallery view markup, set corresponding attributes
  render: ->
    @images = { 'collection': [] }
    # grab all image link, store them into images collection
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
    # set all image source to blank image before remove everything,
    # in order to release more memory
    this.$el.find('img').forEach (item)->
      $(item).attr('src', '/images/blank.gif')
    @galleryWrapper.html('')

  # overwrite SwipeView#moveRight, adds page number update
  moveRight: ->
    # increase current page number tracker if it's not on last page
    @currentPageCount += 1 if @currentPageCount < @bufferSize
    this.slideTo("next")
    this.updatePageTracker()

  # overwrite SwipeView#moveLeft, adds page number update
  moveLeft: ->
    # decrease current page number tracker if it's not on first page
    @currentPageCount -= 1 if @currentPageCount > 1
    this.slideTo("prev")
    this.updatePageTracker()

  # update current page number, eg. 1 of 5, 2 of 5...
  # update pagination dot status
  updatePageTracker: ->
    @pageTracker.html(@currentPageCount + ' of ' + @bufferSize)
    @pagePagination.find('.bullet.selected').removeClass('selected')
    @pagePagination.find('.bullet:nth-child(' + @currentPageCount + ')').addClass('selected')