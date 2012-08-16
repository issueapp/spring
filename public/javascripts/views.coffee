root = exports ? this


random_img = (width, height) ->
  kw = ["fashion", "timeless", "intense,look", "lookbook", "vintage", "street,fashion", "paris,fashion", "old,clock", "cat,women", "sexy,fashion"]
  randno = Math.floor ( Math.random() * kw.length )
  width ||=  "1024"
  height ||= "600"

  "http://flickholdr.com/#{width}/#{height}/#{kw[randno]}/bw";

root.items =[]
for i in [0 ... 50]
  root.items.push(
    id: i
    title: "Page " + i 
    url: "/products/" + i
    thumb: random_img()
  )

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
class root.PageView extends Backbone.View
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
    
    console.log(section_tpl, source, index)
    
    @items = []
    @template = $(source)
    @limit = @template.find('.item').length

  addItem: (item)->
    @items.push(item) 

  isFull: ->
    
    console.log('PageView#isFull', @limit, @items.length >= @limit)
    @items.length >= @limit
  
  render: ->
    @items.forEach (item, index)=>
      node = @template.find(".item").eq(index)
      
      tpl = Milk.render('<div class="image cover"><img src="{{ thumb }}"></div><div class="info"><h3 class="title">{{ title }}</h3></div>', item)
      
      # console.log(node, tpl)
      
      node.html(tpl)
    
    @template
  
###
  Stream View that many sliding pages
  
  
  - Section page templates with 3 styles
  - Randomly select a style, it workout number of slots
  - 
  
###

class root.StreamView extends Backbone.View
  
  initialize: (data)->
    @current_page = null
    @pages = []
    @items = data.items || []
    
    @container = document.querySelector('.scrollable.horizontal');
    @scroller = directions.horizontal(@container);
    
  # prepare data into seperate pages    
  prepare: ->
    page = null
    @items.forEach (item, index) =>
      if not page? or page.isFull()
        page = new PageView
        @pages.push(page)
      
      page.addItem(item)
  
  render: ->
    this.prepare()
    @pages.forEach (page, i)=>
      node = page.render()
      console.log("aaa", node)
      $(@el).append( node )
      
