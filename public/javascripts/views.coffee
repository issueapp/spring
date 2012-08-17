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
  # Page.plan([1,2,3,4,5])
  # => [ <Page 1,2,3>, <Page 4,5> ]
  # 
  # @plan: (products) ->
  #   view = new PageView
  # 
  #   reminding products = view.fill(products)
  # 
  #   products
  # 
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
  initialize: ->
    section_tpl = $('script.section_tpl')
    index = Math.floor(Math.random() * section_tpl.length)
    source = section_tpl.eq(index).html()
        
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
      
      tpl = Milk.render('<div class="image cover"><img src="{{ thumb }}"></div><div class="info"><h3 class="title">{{ title }}</h3></div>', item)
      
      # console.log(node, tpl)
      
      node.html(tpl)
    
    this.setElement(@template)
    
    @template

class App.StreamCollection extends Backbone.Collection
  
  initialize: ->
    @offset ||= 0
    
    @perPage ||= 10
    @page ||= 1
    
  # End of stream
  eos: ->
    @offset == @length - 1

    
  #     |   |
  # [a,b,c,d,e]
  #    ^
  # [1,2,3,4,5,6,7,8,9,10,11,12,14]
  #       |       |      |
  fill: (page)->
    current = null
    page.items ||= []

    this.forEach (item, index) =>
      if @offset > 0
        lowerBound = index > @offset
        upperBound = index <= page.limit + @offset
        
      else if @offset == 0
        lowerBound = index >= @offset
        upperBound = index < page.limit + @offset
        
      if lowerBound and upperBound
        page.addItem( item.toJSON() )
        current = index
    @offset = current

  pageInfo: ->
    info = {
      total: @total
      page: @page
      perPage: @perPage
      pages: Math.ceil(@total / @perPage)
      prev: false
      next: false
    }

  nextPage: ->

###
  Stream View that many sliding pages
  
  - Section page templates with 3 styles
  - Randomly select a style, it workout number of slots
  
###
class App.StreamView extends Backbone.View
  
  initialize: (data)->
    @currentIndex ||= 0
    @pageEvent = null
    @direction
    @pages = []
    @limit = 3
    @container = $(@el).parent()[0]
    
    # @container = document.querySelector('.scrollable.horizontal');
    if directions
      @scroller = this.getScroller()
    # 
    @collection.on("refresh", this.render)
    
    $(@container).on "scrollability-page", (event, a, b)=>

      @pageEvent = event

      
    $(@container).on "scrollability-end", (event)=>
      
      delta = @pageEvent.page - @currentIndex
      
  
      
      if delta > 0
        @direction = 'right'
        this.next(@pageEvent)
        
      else if delta < 0
        @direction = 'left'
        this.prev(@pageEvent)
      
      target = @pages[@pageEvent.page]
      
      console.log("scrollability-end", delta, target)
      
      
      @currentIndex = @pageEvent.page

      
      $(@el).find('.page').removeClass('current')
      $(target.el).addClass('current')
      
  
  getScroller: ->
    directions.horizontal(@container)
  
  next: (event)->
    
    console.log(@direction, event)
    
    # has far next
    unless @pages[event.page + 1]
      
      page = this.buildPage()
      this.insert( page )
      
      console.log('event: far next empty', @pages.length)

      # pop the front
      # 
      # mostLeft.remove()
      # @currentIndex = @currentIndex - 1
    else
      page = @pages[event.page]
    page
    
  prev: (event)->
    target = @pages[event.page]
    
    # has far next
    unless @pages[event.page - 1]
      console.log('event: far left empty')
      
      
  buildPage: ->
    page = new App.PageView
    @collection.fill(page)
    @pages.push(page)
    
    page
    
    
  # prepare data into seperate pages    
  prepare: ->
    until @pages.length == @limit
      this.buildPage()

  updatePos: (offset)->
    scroller = this.getScroller()
    pos = scroller.position

    animation = scroller.node.style.webKitAnimation 
    scroller.node.style.removeProperty('-webkit-animation')
    # scroller.node.style.webKitAnimation = ''
    # scroller.node.style.webkitAnimationPlayState  =''
    scroller.node.style.webkitTransform = scroller.update(pos + offset)
    
    scroller.node.style.webKitAnimation = animation
    
    console.log(pos, scroller.update(pos + offset))

  insert: (page)->
    scroller = this.getScroller()
    console.log('insert', page)

    if @direction == 'right'
      $(@el).append( page.render() )
      
      page = @pages.shift()
      page.remove()
      
      @currentIndex = @currentIndex - 1
      
      this.updatePos(1024)
      
      console.log(page)
      
  render: =>
    this.prepare()

    @pages.forEach (page, i)=>
      node = page.render()
      $(@el).append( node )
      
    $(@pages[0].el).addClass('current')