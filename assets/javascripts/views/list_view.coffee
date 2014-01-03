class App.ListView extends Backbone.View
  initialize: (data)->
    @title = "TOP CONTENT"
    @currentIndex ||= 0
    @pageEvent = null
    @direction ||= "down"
    @pages = []
    @limit = 3
    
    @toolbar = new App.Toolbar
    
    # Render stream once data is loaded
    @collection.on("reset", this.render)
    
    $(@el).on "swipeDown", =>
      @changedDir = @direction != "down"
      @direction = "down"
    
    $(@el).on "swipeUp", =>
      @changedDir = @direction != "up"
      @direction = "up"

    loading = false
    
    # Switched page
    #  event.page = non zero page index
    $(@el).on "scrollability-page", (event, a, b)=>
      # console.warn("Switched Page", @changedDir, event.page, @currentIndex)
      
      # return if loading
      # Start page change
      if @direction == "down"
        loading = true
        target = this.next()
        
      else if @direction == "up"
        loading = true
        target = this.prev()
      
      if target = @pages[@currentIndex]
        # Add current class
        $(@el).find('.page').removeClass('current').removeClass('prev').removeClass('next')
        
        target.active()
        
        $(target.el).next().addClass('next') if $(target.el).next()
        
        loading = false
        
      this.renderInfo()
      
  render: =>
    firstRender = @pages.length == 0
    @scroller ||= this.getScroller()
    
    until @pages.length == @limit
      page = this.appendPage(false)
      this.renderPage(page, 'append', false)
    
    if firstRender
      this.firstPage().offset = this.firstPage().limit

      $(this.firstPage().el).addClass('current')
      $(@pages[1].el).addClass('next')

  appendPage: (render)->
    render ?= true
    target = this.lastPage()
    offset = target && target.offset || 0
    page = new App.PageView(method: 'append', stream: this, isMobile: true)
    
    @collection.fill(page, offset, false, true)
    
    return if page.items.length == 0

    # push and pop
    @pages.push(page)

    if render == true
      # Render
      # maintain index
      @currentIndex = @currentIndex - 1
      this.renderPage(page, 'append') 

    page
    
  firstPage: -> @pages[0]

  lastPage: -> @pages[@pages.length - 1]

  currentPage: -> @pages[@currentIndex]
  
  getScroller: ->
    if directions == undefined
      directions = scrollability && scrollability.directions
    
    directions && directions.vertical(@el)
    
  renderPage: (page, method, reposition)->
    reposition ?= true
    method ?= 'append'
    pos = 1024
    
    # Render
    node = page.render()
    # node.css('visibility', 'hidden')

    if method == 'prepend'
      # $(@el).prepend( node )

      @padding.after(node)
      pos = -pos
    else
      $(@el).append( node )

    $(node).attr('data-offset', page.offset)

    node