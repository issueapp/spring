root = exports ? this


random_img = (width, height) ->
  kw = ["fashion", "timeless", "intense,look", "lookbook", "vintage", "street,fashion", "paris,fashion", "old,clock", "cat,women", "sexy,fashion"]
  randno = Math.floor ( Math.random() * kw.length )
  width ||=  "1024"
  height ||= "600"

  "http://flickholdr.com/#{width}/#{height}/#{kw[randno]}/bw";

root.items =[]
for i in [0 ... 100]
  root.items.push(
    id: i
    title: "Page " + i + " title" + new Date
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

  initialize:
    section_tpl = $('script.section_tpl')
    source = section_tpl.eq(Math.floor(Math.random() * section_tpl.length) + 1).html()
    @template = $(template)
    @limit = @template.find('.item').length

###
  Stream View that manages slide
###

class root.StreamView extends Backbone.View
  pages: []
  current_page: null
  
  renderItem: (item)->
    
    if @pages.length == 0
      new PageView
      
    item

# Domready
$ ->
  container = $('[role=main]')
  _(items).each (item)->
    console.log(item)
    

    
    $(template).find('.item').each (e)->
      
    console.log(section_tpl, template)
    $(container).append( Milk.render(template, item) );
