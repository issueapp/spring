###
SwipeView

    padding page
    3 pages
    pageIndex
    bufferSize = 3
    current

    [padding] [ page ]  [ page ]  [ page ]

Events

    fetch:next
    fetch:prev

    buffer:next
    buffer:prev

    destroy

    refresh

Markup

    .swipe-paging
      .page
      .page
      .page
###

class App.SwipeView extends Backbone.View

  el: '.swipe-paging'

  events:
    touchstart: "onTouch"
    touchmove: "onMove"
    touchend: "onTouchEnd"

    swipeLeft: "moveRight"
    swipeRight: "moveLeft"

  initialize: (data)->
    # @viewport ||= @el.parentNode.offsetWidth
    @offset ||= 0
    @currentIndex ||= 0
    @startClientX = @currentClientX = 0
    @bufferSize ||= 3

    # Set current page
    @currentPage = this.$('.current').eq(0)

    if @currentPage.length == 0
      @currentPage = $(@el).children(":not(.padding)").first().addClass('current')

    this.getViewport()
    
    # if expandMenu = $('body.expand-menu')[0]
    #   @viewport ||= expandMenu.offsetWidth
    # else
    #   @viewport ||= @el.parentNode.offsetWidth


    $(document).on 'keydown', (e)=>
      switch (e.which || e.keyCode)
        when 190 then this.moveRight()
        when 188 then this.moveLeft()

  getViewport: ->
    # TODO: This should query the layout manager
    if expendMenu = $('body.expand-menu')[0]
      @viewport ||= expendMenu.offsetWidth
    else
      @viewport ||= @el.parentNode.offsetWidth
  
  onTouch: (e) ->
    e = e.touches[0] if e.touches

    @startClientX = e.clientX
    @startClientY = e.clientY

    $(@el).removeClass('animate').addClass('swiping')

  onMove: (e) ->
    e = e.touches[0] if e.touches
    delta = e.clientX - @startClientX

    return if e.clientY < @startClientY
    
    # moveDelta = e.clientX - @currentClientX
    # console.log(@offset + delta * 1.1)

    this.updatePos(@offset + delta)
    @currentClientX = e.clientX

  onTouchEnd: (e) ->
    e = e.changedTouches[0] if e.changedTouches
    moveDelta = e.clientX - @startClientX
    
    # Stop swiping and animate the left go.
    $(@el).addClass('animate').removeClass('swiping')

    # Snap to the left
    if @offset == 0 && moveDelta > 0
      this.updatePos(0)

    if moveDelta < 0 && this.$('.current').next().length == 0
      this.updatePos(@offset)

  moveRight: -> this.slideTo("next")
  moveLeft: -> this.slideTo("prev")

  slideTo: (dir)->
    if this.$('.padding').length == 0
      # Set padding
      @padding = $('<div class="page padding" style="visibility:hidden;width:0;padding:0;width: 0px; border:0;font-size:0">')

      $(@el).prepend(@padding)

    current = this.$('.current')
    target = current[dir]().not('.padding')
    bufferStep = parseInt(@bufferSize/2)

    if target.length > 0
      # Remove swipe animation, start transition
      $(@el).removeClass('swiping').addClass('animate').css('transform', '')

      # Force viewport if initialize didn't pick it up
      this.getViewport() if @viewport == 0

      if dir == 'next'
        pos = @offset - @viewport
      else
        pos = @offset + @viewport
        bufferStep = -bufferStep

      if pos <= 0
        this.updatePos(@offset = Math.round(pos))

      # Set current
      current.removeClass('current')
      $(target).addClass('current')

    if target.is('.loading')
      this.trigger("fetch:#{dir}", this)

    # Beginning ?
    if @offset == 0 && dir == "prev"
      this.trigger('refresh', this)
    else
      this.bufferPage(dir, bufferStep)

    this.destroyPage(dir, bufferStep)
    this.trigger("slideTo:#{dir}", this)

  bufferPage: (dir, step)->
    index = this.$('.page:not(.padding)').indexOf( this.$('.current')[0] )
    buffered = this.$(".page:not(.padding)")[index + step]

    unless buffered
      this.trigger("buffer:#{dir}", this)

  destroyPage: (dir, step)->
    # clear pages
    paddings = parseInt(@padding.data('pages')) || 0

    if dir == "next"
      paddings += 1
      garbage = this.$(".page:not(.padding)").first()
    else
      paddings = Math.max(paddings - 1, 0)
      garbage = this.$(".page:not(.padding)").last()

    if garbage.length > 0 && this.$(".page:not(.padding)").length > @bufferSize
      this.trigger("destroy", garbage)

      $(garbage).remove()

      @padding.attr('data-pages', paddings)
      @padding[0].style.width = paddings * @viewport

  # When we insert and remove pages, the rendering offset
  updatePos: (offset)->
    @el.style.webkitTransform = 'translate3d(' + offset + 'px, 0, 0)'

