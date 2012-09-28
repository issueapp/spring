  
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
  # events:
  #   'scrollability-page': 'onPageChange'
  #   'scrollability-end': 'onScrollEnd'
    
  initialize: (data)->
    @title = "TOP CONTENT"
    @currentIndex ||= 0
    @pageEvent = null
    @direction ||= "right"
    @pages = []
    @limit = 3
    @layout = data.layout
    @transition = false
    @offset = 0
    
    # @container = $(@el)[0]

    @padding = $('<div class="page padding" style="visibility:hidden;width:0;padding:0;width: 0px; border:0;font-size:0">').appendTo(@el)
    @toolbar = new App.Toolbar
    
    # Render stream once data is loaded
    @collection.on("reset", this.render)
    
    # $(@el).on "swipeLeft", =>
    #   # @changedDir = @direction != "right"
    #   @direction = "right"
    #   # $(@el).attr('data-direction', @direction)
    #   
    # $(@el).on "swipeRight", =>
    #   # @changedDir = @direction != "left"
    #   @direction = "left"
    #   # $(@el).attr('data-direction', @direction)
      
    # Switched page
    #  event.page = non zero page index
    $(@el).on "scrollability-page", (event, a, b)=>
      # console.warn("Switched Page", @changedDir, event.page, @currentIndex)
      
      # return if loading
      # Start page change
      if @direction == "right"
        loading = true
        target = this.next()
        
      else if @direction == "left"
        loading = true
        target = this.prev()
        # console.log(target)
      
      if target = @pages[@currentIndex]
        # Add current class
        $(@el).find('.page').removeClass('current').removeClass('prev').removeClass('next')
        
        target.active()
        
        $(target.el).next().addClass('next')
        $(target.el).prev().addClass('prev')
        $(@el).removeClass('swiping')

        loading = false
        
      this.renderInfo()
    
    # $(@container).on "scrollability-end", (event) =>
    #   console.warn('scrollability-end', @fetchPage)
    #   
    #   if @fetchPage == 'append'
    #     farNext = this.appendPage()
    #     this.clearPage('append')
    #     @fetchPage = false
    #     
    #   else if @fetchPage == 'prepend'
    #     prevNext = this.prependPage()
    #     this.clearPage('prepend')
    #     @fetchPage = false

    # Prevent browser from
    
    startClientX  = currentClientX = 0
    
    $(@el).on "touchstart", (e)=> 
      if e.touches
        e = e.touches[0]
      
      startClientX = e.clientX
      $(@el).removeClass('animate').addClass('swiping')
      
    $(@el).on "touchmove", (e)=>
      e.preventDefault()
      
      if e.touches
        e = e.touches[0]

      delta = e.clientX - startClientX
      moveDelta = Math.abs(e.clientX - currentClientX)
      
      return if currentClientX > 0 && moveDelta < 25

      @el.style.webkitTransform = 'translate3d(' + (@offset + delta * 1.1) + 'px,0,0)'
      currentClientX = e.clientX

    # Mark trasition has ended
    $(@el).on $.fx.transitionEnd, => @transition = false

    $(@el).on "swipeLeft", (e)=>
      # return if @transition
      target = this.next()

      if target      
        $(@el).removeClass('swiping').addClass('animate').css('transform', '')
        
        this.updatePos(- @layout.viewport)
        
        $(@el).find('.page').removeClass('current')
        
        $(target.el).addClass('current')
      
      e.preventDefault()

    $(@el).on "swipeRight", (e)=>
      # return if @transition

      target = this.prev()

      if target
        $(@el).removeClass('swiping').addClass('animate').css('transform', '')

        this.updatePos( @layout.viewport)
        
        $(@el).find('.page').removeClass('current')
        $(target.el).addClass('current')

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
    
      this.renderInfo()
      
  onResize: ->
    paddings = parseInt(this.$('.padding').data('pages')) || 0
    
    $(@el).removeClass('animate')
    
    this.$('.item img').addClass('animate')
    
    if @offset != 0
      @offset = -(paddings + 1) * App.layout.viewport
    
    this.updatePos(0)
    this.updatePadding()

  # onPageChange: (event) =>
  #   console.log("Switched Page: #{event.page}")
  #   @pageEvent = event

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
    
  # 
  # Load previous for page 2 +
  prev: ()->
    if page = @pages[@currentIndex - 1]
      @currentIndex -= 1
      
      step = parseInt(@limit/2)
      
      # Far prev
      unless @pages[@currentIndex - step]
        # @fetchPage = 'prepend'
        farNext = this.prependPage()
        this.clearPage('prepend')
        
      else
        farPrev = @pages[@currentIndex - step]
        
    page

  # When we insert and remove pages, the rendering offset 
  updatePos: (offset)->
    node = @el

    # Necessary to pause animation in order to get correct transform value
    # console.log(node.style.webkitAnimation)
    # console.log(node.style)
    

    @offset = Math.round(@offset + offset)
    
    if @offset <= 0
      node.style.webkitTransform = 'translate3d(' + @offset + 'px, 0, 0)'
      # $(@el).css('-webkit-transform', 'translate3d(' + @offset + 'px,0,0)')

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
    
    # console.warn('Prepend', page, offset, page.items.map (i)-> i.id )
    
    # push and pop
    @pages.unshift(page)
    
    # maintain index
    if render== true
      @currentIndex = @currentIndex + 1
      this.renderPage(page, 'prepend') 
    
    page
    
  appendPage: (render)->
    render ?= true
    target = this.lastPage()
    offset = target && target.offset || 0
    page = new App.PageView(method: 'append', stream: this)

    @collection.fill(page, offset)
    # console.log("renderPage", page)
    
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
    # @padding.width( paddingPages * @scroller.viewport )
    # @padding[0].style.width = paddingPages * @scroller.viewport
    # @padding.width( @padding.width() + scroller.viewport )    
  
  updatePadding: (pages)->
    pages ||= parseInt(this.$('.padding').data('pages') || 0)
    
    @padding[0].style.width = pages * @layout.viewport
  
  renderPage: (page, method, reposition)->
    reposition ?= true
    method ?= 'append'
    pos = 1024
    
    # Render
    node = page.render()
    # node.css('visibility', 'hidden')
    
    if method == 'prepend'
      # $(@el).prepend( node )

      container = @padding.after('<div class="page rotatable"></div>').next()
      pos = -pos
    else
      container = $(@el).append('<div class="page rotatable"></div>').children().last()
    
    setTimeout =>
      container[0].parentNode.replaceChild(node[0], container[0])
      node[0].className = container[0].className
    , 200
    # 
    # this.updatePos(pos) if reposition
    
    $(node).attr('data-offset', page.offset)
    
    node
  
  render: =>
    firstRender = @pages.length == 0

    
    @scroller ||= this.getScroller()
    
    until @pages.length == @limit
    #   page = this.appendPage(false)
    #   this.renderPage(page, 'append', false)
      page = this.appendPage(false)
      # page.offset = page.limit if page.offset == 0
      this.renderPage(page, 'append', false)
    
    if firstRender
      this.firstPage().offset = this.firstPage().limit
  
      $(this.firstPage().el).addClass('current')
      $(@pages[1].el).addClass('next')
    
    @toolbar.title = this.title
    @toolbar.backBtn = false
    @toolbar.signupButton = true
    @toolbar.$('.actions').remove()

    @toolbar.render()

  renderInfo: ->
    # <dt>currentIndex</dt><dd id="stat-stream-index"></dd>
    # <dt>Pages</dt><dd id="stat-pages"></dd>
    # <dt>Page offset</dt><dd id="stat-page-offset"></dd>
    # 
    # <dt>Collection index</dt><dd id="stat-collection-index"></dd>
    # $('#stat-collection-index').html(@collection.offset)
    # $('#stat-stream-index').html(@currentIndex)
    # $('#stat-page-offset').html(this.currentPage().offset )
    # 
    # $('')
    # 
    # $('#stat-items').html('')
    # pages = @pages.map (p)-> 
    #   ids = p.items.map (i)-> i.id
    #   div = $('<div>').html( p.offset + " => " + ids.join(", ")).appendTo($('#stat-items'))
    #   div.css( width: 150, display: "inline-block")
    #   div.css( border: "1px solid red") if $(p.el).is('.current')
