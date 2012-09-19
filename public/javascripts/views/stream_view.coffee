  
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
  events:
    'orientationchange': 'changeOrientation'
    
  initialize: (data)->
    @title = "TOP CONTENT"
    @currentIndex ||= 0
    @pageEvent = null
    @direction ||= "right"
    @pages = []
    @limit = 3
    # @container = $(@el)[0]
    # @scroller = this.getScroller()
    @padding = $('<div class="page padding" style="visibility:hidden;width:0;padding:0;width: 0px; border:0;font-size:0">').appendTo(@el)
    @toolbar = new App.Toolbar
    
    # Render stream once data is loaded
    @collection.on("reset", this.render)
    
    $(@el).on "swipeLeft", =>
      @changedDir = @direction != "right"
      @direction = "right"
      $(@el).attr('data-direction', @direction)
      
    $(@el).on "swipeRight", =>
      @changedDir = @direction != "left"
      @direction = "left"
      $(@el).attr('data-direction', @direction)
      
    loading = false

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
 
    $(document).on 'keydown', (e)=>
      key = e.which || e.keyCode
      pos = @scroller.viewport
      
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
        this.updatePos(pos)
        
        $(@el).find('.page').removeClass('current')
        $(target.el).addClass('current')

      this.renderInfo()

  changeOrientation: (e)->
    @padding.width()

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
    scroller = this.getScroller()
    pos = scroller.position

    animation = scroller.node.style.webKitAnimation 
    scroller.node.style.removeProperty('-webkit-animation')
    # scroller.node.style.webKitAnimation = ''
    # scroller.node.style.webkitAnimationPlayState  =''
    scroller.node.style.webkitTransform = scroller.update(pos + offset)
    scroller.node.style.webKitAnimation = animation

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
    console.log("renderPage", page)
    
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
    
    # @padding.width( paddingPages * @scroller.viewport )
    @padding[0].style.width = paddingPages * @scroller.viewport
    # @padding.width( @padding.width() + scroller.viewport )    
    
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
      node.css('visibility', 'visible')
      node[0].className = container[0].className
    , 300
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
