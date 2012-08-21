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
  
  initialize: ->
    section_tpl = $('script.section_tpl')
    index = Math.floor(Math.random() * section_tpl.length)
    source = section_tpl.eq(index).html()
    
    if window.orientation == 0 or window.orientation == 180
      @page = $(source)
      source = this.flipClass()
      
    @offset = null
    
    @items = []
    @template = $(source)
    @limit = @template.find('.item').length
    
  addItem: (item)->
    @items.push(item) 

  isFull: ->
    @items.length >= @limit
    
  render: ->
    @items.forEach (item, index)=>
      node = @template.find(".item").eq(index)
      
      # Temporary item template
      tpl = Milk.render('<div class="image cover"><img src="{{ thumb }}"></div><div class="info"><h3 class="title">{{ title }}</h3></div>', item)
      
      node.html(tpl)
    
    this.setElement(@template)
    
    @template
    
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
      
      console.log("Reverse: ", index, offset, page.limit) if reverse
      
      if lowerBound and upperBound
        
        page.addItem( item.toJSON() )
        
        if reverse
          current =  Math.max(offset, 0)
        else
          current = index + 1
    
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
    @direction
    @pos
    @pages = []
    @limit = 3
    @container = $(@el)[0]
    @scroller = this.getScroller()
    
    # @container = document.querySelector('.scrollable.horizontal');
    # if directions?
    #   
    # # 
    @collection.on("refresh", this.render)
    
    console.log @currentIndex
    
    $(@container).on "swipeLeft", => @direction = "right"
    $(@container).on "swipeRight", => @direction = "left"
    
    # Switched page
    #  event.page = non zero page index
    $(@container).on "scrollability-page", (event, a, b)=>
      console.log("Switched Page", event.page, @currentIndex)
      @pageEvent = event
    
    # When scroll finish
    $(@container).on "scrollability-end", (event)=>
      return unless @pageEvent

      # Start page change
      if @direction == "right"
        this.next(@pageEvent)
        
      else if @direction == "left"
        this.prev(@pageEvent)
      

      target = @pages[@currentIndex]
      console.log('Current', @direction,  @currentIndex, @pages[@currentIndex])
            
      # Add current class
      $(@el).find('.page').removeClass('current')
      $(target.el).addClass('current')
      
      this.renderInfo()
      @pageEvent = false
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
  next: (event)->
    unless @pages[@currentIndex + 2]
      console.log "Before append page:", @currentIndex
      @currentIndex +=1
      this.appendPage()
      console.log "After append page:", @currentIndex
      
    else
      @currentIndex += 1
      @pages[@currentIndex + 1]
  
  # 
  # Load previous for page 2 +
  prev: (event)->
    unless @currentIndex != 0 and @pages[@currentIndex - 2]
      @currentIndex -= 1
      this.prependPage()
    else
      @currentIndex -= 1
      @pages[@currentIndex - 1]

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
    page = new App.PageView
    
    @collection.fill(page, offset, true)
    
    console.warn('prepend', page, offset)
    
    # push and pop
    @pages.unshift(page)
    this.clearPage('prepend')
    
    # maintain index
    if render== true
      @currentIndex = @currentIndex + 1
      this.renderPage(page, 'prepend') 
    
    page
    
  appendPage: (render)->
    render ?= true
    target = this.lastPage()
    offset = target && target.offset || 0
    page = new App.PageView
    
    @collection.fill(page, offset)
    
    # push and pop
    @pages.push(page)
    this.clearPage('append')

    if render == true
      # Render
      # maintain index
      @currentIndex = @currentIndex - 1
      this.renderPage(page, 'append') 
    
    page
  
  clearPage: (method)->
    return if @pages.length <= @limit
    
    if method == 'append'
      page = @pages.shift()
    else
      page = @pages.pop()
      
    page.remove()
        
  renderPage: (page, method, reposition)->
    reposition ?= true
    method ?= 'append'
    pos = 1024
    
    # Render
    node = page.render()
    
    if method == 'prepend'
      $(@el).prepend( node )
      pos = -pos
    else
      $(@el).append( node )
    
    this.updatePos(pos) if reposition
    
    node
  
  render: =>
    
    until @pages.length == @limit
    #   page = this.appendPage(false)
    #   this.renderPage(page, 'append', false)
      page = this.appendPage(false)
      this.renderPage(page, 'append', false)
    
    $(this.firstPage().el).addClass('current')

  renderInfo: ->
    # <dt>currentIndex</dt><dd id="stat-stream-index"></dd>
    # <dt>Pages</dt><dd id="stat-pages"></dd>
    # <dt>Page offset</dt><dd id="stat-page-offset"></dd>
    # 
    # <dt>Collection index</dt><dd id="stat-collection-index"></dd>
    
    $('#stat-stream-index').html(@currentIndex)
    $('#stat-page-offset').html(this.currentPage().offset )
  