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
    
    @template

class App.StreamCollection extends Backbone.Collection
  
  initialize: ->
    @offset ||= 0
    
    @perPage ||= 10
    @page ||= 1
    
  # End of stream
  eos: ->
    @offset == @length - 1

  fill: (page)->
    current = null
    page.items ||= []
    
    #     |   |
    # [a,b,c,d,e]
    #    ^
    
    this.forEach (item, index) =>
      
      if @offset > 0
        #  index : 2
        lowerBound = index > @offset
        upperBound = index <= page.limit + @offset
        
      else if @offset == 0
        lowerBound = index >= @offset
        upperBound = index < page.limit + @offset
        
      # lowerBound = index >= @offset + 1
      # upperBound = index < page.limit + @offset
      
      
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
    @currentIndex = null
    @pages = []
    @limit = 30
    
    # @container = document.querySelector('.scrollable.horizontal');
    # if directions
    #   @scroller = directions.horizontal(@el)
    # 
    @collection.on("refresh", this.render)
    
    console.log(@el)
    $(@el).parent().on "scrollability-end", (event)->
      console.log(event.page)
      
    
  # prepare data into seperate pages    
  prepare: ->
    # [1,2,3,4,5,6,7,8,9,10,11,12,14]
    #       |       |      |
    
    until @pages.length == @limit
    
      page = new App.PageView
      @collection.fill(page)
    
      @pages.push(page)
    
    # 
    # if @pages.length > @limit
    #   @pages
    # 
        
      
    
        # 
        # 
        # if @collection.
        # page = null
        # 
        # @collection.each (item, index) =>
        #   if not page? or page.isFull()
        #     page = new App.PageView
        #     @pages.push(page)
        #   
        #   page.addItem(item.toJSON())
  
  render: =>
    this.prepare()

    @pages.forEach (page, i)=>
      node = page.render()
      $(@el).append( node )
      
