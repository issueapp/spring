
###
  Stream View that many sliding pages

  - It has a swipe view
  - Section page templates with 3 styles
  - Randomly select a style, it workout number of item slots
  - Navigate to different pages across available dataset

  Renering window has 3 pages

  Data source

    [a b c d; e f g h;i j k l ;m n o p; qrstuvwxyz]

    Initial
    |  <P1> |  <P2>  |  <p3>   |
        ^

    Next page
    |  <P1> |  <P2>  |  <p3>   |
                ^

    Next and load new page, kill P1
    |       |  <P2>  |  <p3>   |  <P4>  |
                          ^

###
class App.StreamView extends Backbone.View

  initialize: (data)->
    @title = data.title || "Top content"
    @currentIndex ||= 0
    @pageEvent = null
    @direction ||= "right"
    @pages = []
    @limit = 3
    @layout = data.layout
    @transition = false
    @offset = 0
    @newChannel = data.newChannel

    # reset view
    this.$el.removeAttr("style").html('')
    this.$el.off()

    @padding = $('<div class="page padding" style="visibility:hidden;width:0;padding:0;border:0;font-size:0">').appendTo(@el)
    @toolbar = App.toolbar || new App.Toolbar

    # Render stream once data is loaded
    @collection.on("reset", => this.render())

    # Switched page
    # event.page = non zero page index
    # $(@el).on "scrollability-page", (event, a, b)=>
    #   # return if loading
    #   # Start page change
    #   if @direction == "right"
    #     loading = true
    #     target = this.next()
    # 
    #   else if @direction == "left"
    #     loading = true
    #     target = this.prev()
    # 
    #   if target = @pages[@currentIndex]
    #     # Add current class
    #     $(@el).find('.page').removeClass('current').removeClass('prev').removeClass('next')
    # 
    #     target.active()
    # 
    #     $(target.el).next().addClass('next')
    #     $(target.el).prev().addClass('prev')
    #     $(@el).removeClass('swiping')
    # 
    #     loading = false

    # Prevent browser from
    startClientX = currentClientX = 0

    $(@el).on "touchstart", (e)=>
      if e.touches
        e = e.touches[0]

      startClientX = e.clientX
      $(@el).removeClass('animate').addClass('swiping')

    loadingImage = false

    $(@el).on "touchmove", (e)=>
      e.preventDefault()

      if e.touches
        e = e.touches[0]

      delta = e.clientX - startClientX
      moveDelta = Math.abs(e.clientX - currentClientX)
      
      # return if currentClientX > 0 && moveDelta < 25
      
      @el.style.webkitTransform = 'translate3d(' + (@offset + delta) + 'px,0,0)'
      currentClientX = e.clientX

    # Mark trasition has ended
    $(@el).on $.fx.transitionEnd, => @transition = false

    $(@el).on "swipeLeft", (e)=>
      @changedDir = @direction != "right"
      @direction = "right"
      target = this.next()
      loadingImage = false

      if target
        $(@el).removeClass('swiping').addClass('animate').css('transform', '')
        this.updatePos(- @layout.viewport)
        $(@el).find('.page').removeClass('current').css('visibility', 'visible')
        $(target.el).addClass('current')

        this.updateBackgroundImage($(target.el)) if $(target.el).find('.image').css('background-image') == 'none'
        this.updateBackgroundImage($(target.el).next().css('visibility', 'hidden'))

        # remove previous page background image after 200ms
        setTimeout =>
          target.$el.prev().find('.image').forEach (item) ->
            $(item).css("background-image", 'none')
          target.$el.prev().css('visibility', 'hidden')
        , 200

      e.preventDefault()

    $(@el).on "swipeRight", (e)=>
      @changedDir = @direction != "left"
      @direction = "left"
      target = this.prev()
      loadingImage = false

      if target
        $(@el).removeClass('swiping').addClass('animate').css('transform', '')
        this.updatePos(@layout.viewport)
        $(@el).find('.page').removeClass('current').css('visibility', 'visible')
        $(target.el).addClass('current')

        this.updateBackgroundImage($(target.el)) if $(target.el).find('.image').css('background-image') == 'none'
        this.updateBackgroundImage($(target.el).prev().css('visibility', 'hidden'))

        # remove previous page background image after 200ms
        setTimeout =>
          target.$el.next().find('.image').forEach (item) ->
            $(item).css("background-image", 'none')
          target.$el.next().css('visibility', 'hidden')
        , 200

      # Snap to the left
      @el.style.webkitTransform = 'translate3d(0,0,0)' if @offset == 0

      e.preventDefault()

    $(document).on 'keydown', (e)=>
      key = e.which || e.keyCode
      pos = @layout.viewport

      if key == 39
        @changedDir = @direction != "right"
        @direction = "right"

        target = this.next()
        pos = -pos
      else if key == 37
        @changedDir = @direction != "left"
        @direction = "left"

        target = this.prev()
      # Add current class

      if target
        if @transition
          $(@el).removeClass('animate')
        else
          $(@el).addClass('animate').css('transform', '')

        this.updatePos(pos)

        $(@el).find('.page').removeClass('current')
        $(target.el).addClass('current')
      # this.renderInfo()

  onResize: ->
    paddings = parseInt(this.$('.padding').data('pages')) || 0

    $(@el).removeClass('animate')

    # this.$('.item img').addClass('animate')

    if @offset != 0
      @offset = -(paddings + 1) * App.layout.viewport

    this.updatePos(0)
    this.updatePadding()

  # Convient helpers
  getScroller: ->
    if directions == undefined
      directions = scrollability && scrollability.directions
    directions && directions.horizontal(@el)

  firstPage: -> @pages[0]

  lastPage: -> @pages[@pages.length - 1]

  currentPage: -> @pages[@currentIndex]

  # Navigation
  next: (step)->
    if page = @pages[@currentIndex + 1]
      # Immediate next
      @currentIndex += 1
      step = parseInt(@limit/2)

      # Far next
      unless @pages[@currentIndex + step]
        farNext = this.appendPage()
        this.clearPage('append')
        # @fetchPage = 'append'
      else
        farNext = @pages[@currentIndex + step]

    page

  # Load previous for page 2 +
  prev: ()->
    if page = @pages[@currentIndex - 1]
      @currentIndex -= 1

      step = parseInt(@limit/2)

      # Far prev
      if this.$el.find('.padding').css('width') != '0px'
        # @fetchPage = 'prepend'
        farNext = this.prependPage()
        this.clearPage('prepend')

      else
        farPrev = @pages[@currentIndex - step]

    page

  # When we insert and remove pages, the rendering offset
  updatePos: (offset)->
    @offset = Math.round(@offset + offset)

    if @offset <= 0
      @el.style.webkitTransform = 'translate3d(' + @offset + 'px, 0, 0)'

    # Mark transition started
    @transition = true

  prependPage: (render)->
    render ?= true
    first = this.firstPage()
    offset = first && first.offset || 0
    page = new App.PageView(method: 'prepend', stream: this)

    offset = offset - this.currentPage().limit

    @collection.fill(page, offset, true) if offset > 0

    return if page.items.length == 0

    # push and pop
    @pages.unshift(page)

    # maintain index
    if render == true
      @currentIndex = @currentIndex + 1
      this.renderPage(page, 'prepend')

    page

  appendPage: (render)->
    render ?= true
    target = this.lastPage()
    offset = target && target.offset || 0
    if @newChannel
      App.PageView.templateIndex = -1
      @newChannel = false

    page = new App.PageView(method: 'append', stream: this)
    @collection.fill(page, offset)

    return if page.items.length == 0

    # push and pop
    @pages.push(page)

    if render == true
      # Render
      # maintain index
      @currentIndex = @currentIndex - 1
      this.renderPage(page, 'append')

    page

  clearPage: (method)->
    return if @pages.length <= @limit
    paddingPages = parseInt(@padding.data('pages')) || 0

    if method == 'append'
      page = @pages.shift()
      page.destroy()
      paddingPages += 1
    else
      page = @pages.pop()
      page.destroy()
      paddingPages -= 1

    page = null

    @padding.attr('data-pages', paddingPages)
    this.updatePadding(paddingPages)

  updatePadding: (pages)->
    pages ||= parseInt(this.$('.padding').data('pages') || 0)

    @padding[0].style.width = pages * @layout.viewport

  renderPage: (page, method, reposition)->
    reposition ?= true
    method ?= 'append'
    pos = 1024

    # Render
    node = page.render()

    if method == 'prepend'
      container = @padding.after('<div class="page rotatable"></div>').next()
      pos = -pos

    else
      container = $(@el).append('<div class="page rotatable"></div>').children().last()

    container[0].parentNode.replaceChild(node[0], container[0])
    node[0].className = container[0].className

    $(node).attr('data-offset', page.offset)

    node

  render: ->
    firstRender = @pages.length == 0
    @scroller ||= this.getScroller()

    until @pages.length == @limit
      page = this.appendPage(false)
      this.renderPage(page, 'append', false)

    if firstRender
      this.firstPage().offset = this.firstPage().limit
      this.firstPage().$el.addClass('current')
      this.updateBackgroundImage(@pages[0].$el)
      this.updateBackgroundImage(@pages[1].$el)
    
    @toolbar.render(title: @title, typeBtn: true)

    this

  updateBackgroundImage: (target) ->
    target.find('.image').forEach (item) ->
      $(item).css("background-image", 'url(' + $(item).data('original') + ')') if $(item).data('original')
