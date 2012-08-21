this.App ||= {}


###
 Page contain multiple rows

  Example:

    [
      { title: 'a', image_height: 100, image_width: 100 },
      { title: 'b', image_height: 200, image_width: 100 }, // tall
      { title: 'c', image_height: 100, image_width: 200 }, // tall
    ]

    p = new Page([1,2,3,4,5])

    p.render
    div.page
      div.row [ 1 ]
      div.row [ 2 ]
      div.row [ 3 ]
###
class App.PageView extends Backbone.View
  # constructor: (width, height)->
  #   @width = width
  #   @height = height
  #   @limit = 3
  #   @products = products
  #   @rows = []
  # 
  # fill: (products)->
  # 
  # render: ->
  events:
    'orientationchange': 'flipClass'

  @templateIndex = -1
  @order = []
  until @order.length == 10
    @order.push Math.floor(Math.random() * $('script.section_tpl').length)
  
  @getTemplate = (data)=>
    section_tpl = $('script.section_tpl')
    
    if data.method == 'append'
      if data.stream.changedDir
        @templateIndex += 2 
        
      @templateIndex += 1
      @templateIndex = 0 if @templateIndex > 9
      
    else
      if data.stream.changedDir
        @templateIndex -= 2 
        
      @templateIndex -= 1
      @templateIndex = 9 if @templateIndex < 0

    index = @order[@templateIndex]
    section_tpl.eq(index).html()

  initialize: (data)->
    # 1 , 2 ,3
    @offset = null
    
    @items = []
    @page = $(App.PageView.getTemplate(data))
    @limit = @page.find('.item').length
    
    if window.orientation == 0 or window.orientation == 180
      this.flipClass()
  
  addItem: (item)->
    @items.push(item) 

  isFull: ->
    @items.length >= @limit
    
  render: ->
    @items.forEach (item, index)=>
      node = @page.find(".item").eq(index)
      
      # Temporary item template
      tpl = Milk.render('<div class="image cover"><img height="{{ image_height }}" width="{{ image_width }}" src="{{ image_url }}"></div><div class="info"><h3 class="title">{{ title }}</h3></div>', item)
      
      node.html(tpl)
    
    this.setElement(@page)
    
    @page
    
  flipClass: ->
    @page ||= $('.rotatable')
    
    if @page.find('.v-half') && !@page.find('.v-half').hasClass('row')
      this.doFlipClass(
        @page,
        ['.v-half.nosplit', '.v-half', '.v-third-2', '.v-third.split', '.v-third'],
        ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third'],
        ['half split', 'half', 'third-2', 'third nosplit', 'third']
      )
    else
      this.doFlipClass(
        @page,
        ['.half.split', '.half', '.third-2', '.third.nosplit', '.third'],
        ['half split', 'half', 'third-2', 'third nosplit', 'third'],
        ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third']
      )

    if @page.find('.row.v-half').length > 0
      this.doFlipClass(@page, ['.row.v-half'], ['row v-half'], ['col half'])
    else
      this.doFlipClass(@page, ['.col.half'], ['col half'], ['row v-half'])
      
    @page

  doFlipClass: (page, classNames, oldNames, newNames)->
    classNames.forEach (className, index)->
      page.find(className).forEach (element)->
        $(element).removeClass(oldNames[index]).addClass(newNames[index])
    
class App.StreamCollection extends Backbone.Collection
  
  initialize: ->
    @offset ||= 0
    @perPage ||= 10
    @page ||= 1
    
  # End of stream
  eos: ->
    @offset == @length

  # seek and fill a set of items into a page
  #     |   |
  # [a,b,c,d,e]
  #    ^
  # [ a,b,c;d,e,f,g;h,i,j;k,l,m,n; ]
  #   |     |       |     |       |
  fill: (page, offset, reverse)->
    reverse ||= false
    offset ||= @offset
    current = 0
    page.items ||= []
    # if reverse
    #   fromIndex = @offset - page.limit
    #   toIndex = @offset
    # else
    #   fromIndex = @offset
    #   toIndex = @offset + page.limit
    
    # return 0 if reverse && offset == 0
    
    if reverse
      offset = offset - page.limit
      
    else
      offset = offset
    
    this.forEach (item, index) =>
      
      lowerBound = index >= offset
      upperBound = index < offset + page.limit
      
      if lowerBound and upperBound
        console.log(" before: ", item, index)

        page.addItem( item.toJSON() )
        
        if reverse
          current =  Math.max(offset + page.limit, 0)
        else
          current = index + 1
    
    console.log("Reverse: #{reverse}", offset, current, page.items.map (i)-> i.id )
    
    @offset = page.offset = current

  pageInfo: ->
    info = {
      total: @total
      page: @page
      perPage: @perPage
      pages: Math.ceil(@total / @perPage)
      prev: false
      next: false
    }

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
    @currentIndex ||= 0
    @pageEvent = null
    @direction ||= "right"
    @pages = []
    @limit = 3
    @container = $(@el)[0]
    @scroller = this.getScroller()
    @padding = $('<div class="page padding" style="visibility:hidden;width:0;padding:0;width: 0px; border:0;font-size:0">').appendTo(@el)
    
    @collection.on("refresh", this.render)
    
    $(@container).on "swipeLeft", =>
      @changedDir = @direction != "right"
      @direction = "right"
    
    $(@container).on "swipeRight", =>
      @changedDir = @direction != "left"
      @direction = "left"
    
    # Switched page
    #  event.page = non zero page index
    $(@container).on "scrollability-page", (event, a, b)=>
      console.warn("Switched Page", @changedDir, event.page, @currentIndex)

      # Start page change
      if @direction == "right"
        target = this.next()
        
      else if @direction == "left"
        target = this.prev()
        console.log(target)
      
      if target = @pages[@currentIndex]
        # Add current class
        $(@el).find('.page').removeClass('current')
        $(target.el).addClass('current')
    
      this.renderInfo()
    
    $(document).on 'keydown', (e)=>
      key = e.which || e.keyCode
      pos = 1024
      
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
  # 
  # onPageChange: (event) =>
  #   console.log("Switched Page: #{event.page}")
  #   @pageEvent = event

  # Convient helpers
  getScroller: ->
    if directions == undefined
      directions = scrollability && scrollability.directions
      
      
    directions && directions.horizontal(@container)

  firstPage: -> @pages[0]

  lastPage: -> @pages[@pages.length - 1]

  currentPage: -> @pages[@currentIndex]
  
  # Navigation
  next: (step)->
    if page = @pages[@currentIndex + 1]
      # Immediate next
        @currentIndex += 1
        
      # Far next
      unless @pages[@currentIndex + 1]
        farNext = this.appendPage()
        this.clearPage('append')
      else
        farNext = @pages[@currentIndex + 1]

    page
    
  # 
  # Load previous for page 2 +
  prev: ()->
    if page = @pages[@currentIndex - 1]
      @currentIndex -= 1
      
      # Far prev
      unless @pages[@currentIndex - 1]
        # alert 'prepend'
        farPrev = this.prependPage()
        this.clearPage('prepend')
  
      else
        farPrev = @pages[@currentIndex - 1]
      
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
    console.log(page, offset)
    
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
    scroller = this.getScroller()
    
    if method == 'append'
      page = @pages.shift()
      page.remove()
      @padding.width( @padding.width() + scroller.viewport )
      
    else
      page = @pages.pop()
      page.remove()
      @padding.width( @padding.width() - scroller.viewport )
      
    
    
  renderPage: (page, method, reposition)->
    reposition ?= true
    method ?= 'append'
    pos = 1024
    
    # Render
    node = page.render()
    
    if method == 'prepend'
      # $(@el).prepend( node )
      
      @padding.after(node)
      pos = -pos
    else
      $(@el).append( node )
    
    # this.updatePos(pos) if reposition
    
    $(node).attr('data-offset', page.offset)
    
    node
  
  render: =>
    until @pages.length == @limit
    #   page = this.appendPage(false)
    #   this.renderPage(page, 'append', false)
      page = this.appendPage(false)
      # page.offset = page.limit if page.offset == 0
      this.renderPage(page, 'append', false)
    
    this.firstPage().offset = this.firstPage().limit
    
    $(this.firstPage().el).addClass('current')

  renderInfo: ->
    # <dt>currentIndex</dt><dd id="stat-stream-index"></dd>
    # <dt>Pages</dt><dd id="stat-pages"></dd>
    # <dt>Page offset</dt><dd id="stat-page-offset"></dd>
    # 
    # <dt>Collection index</dt><dd id="stat-collection-index"></dd>
    $('#stat-collection-index').html(@collection.offset)
    $('#stat-stream-index').html(@currentIndex)
    $('#stat-page-offset').html(this.currentPage().offset )
    
    $('#stat-items').html('')
    pages = @pages.map (p)-> 
      ids = p.items.map (i)-> i.id
      div = $('<div>').html( p.offset + " => " + ids.join(", ")).appendTo($('#stat-items'))
      div.css( width: 150, display: "inline-block")
      div.css( border: "1px solid red") if $(p.el).is('.current')
    
