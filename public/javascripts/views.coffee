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
class this.PageView

  # Page.plan([1,2,3,4,5])
  # => [ <Page 1,2,3>, <Page 4,5> ]
  
  @plan: (products) ->
    view = new PageView
    
    reminding products = view.fill(products)
    
    products

  constructor: (width, height)->
    @width = width
    @height = height
    @limit = 3
    @products = products
    @rows = []
  
  fill: (products)->
    
    

  render: ->
