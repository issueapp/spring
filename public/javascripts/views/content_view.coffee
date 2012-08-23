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
class App.ContentView extends Backbone.View
  # Uses product template.
  el: "article.page"
  
  template: Mustache.compile($('#product_tpl').html())
  
  # events:
  #   'click .item a.link': 'viewContent'
  #   'orientationchange': 'changeOrientation'
  initialize: ->
    @toolbar = new App.Toolbar
    
  render: ->
    @toolbar.title = @model.get('title')
    @toolbar.backBtn = true
    $(@toolbar.el).append($('<div class="actions">
      <i class="icon-heart"></i>
      <i class="icon-plus"></i>
      <i class="icon-share-alt"></i>    
    </div>'))
    
    source = @template(@model.toJSON())
    this.setElement( $(source) )
    
    
    $('#content').append(@el)    
    
    @toolbar.render()
    
  # viewContent: ->
  #   
  # changeOrientation: ->
    