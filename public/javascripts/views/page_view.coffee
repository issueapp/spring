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
    'orientationchange': 'changeOrientation'

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
      this.changeOrientation()
  
  addItem: (item)->
    @items.push(item) 

  isFull: ->
    @items.length >= @limit
    
  render: ->
    @items.forEach (item, index)=>
      node = @page.find(".item").eq(index)
      
      # Temporary item template
      tpl = Milk.render('<div class="image cover"><img src="{{ image_url }}"></div><div class="info"><h3 class="title">{{ title }}</h3></div>', item)
      
      node.html(tpl)
    
    this.setElement(@page)
    
    @page
    
  changeOrientation: ->
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