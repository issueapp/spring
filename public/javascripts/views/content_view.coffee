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
  # el: "article.page"
  el: "#content .pages"
  
  template: Mustache.compile($('#product_tpl').html())
  
  events:
    'swipeLeft': 'viewNext'
  
  initialize: ->
    @toolbar = new App.Toolbar
    @padding = $(@el).find('.page.padding')
    
    if @padding.size() == 0
      $('<div class="page padding" style="visibility:hidden;width:0;padding:0;width: 0px; border:0;font-size:0">').appendTo(@el)
    
  render: ->
    # console.log 'content_view', @model
    @toolbar.title = @model.get('title')
    @toolbar.backBtn = true
    $(@toolbar.el).append($('<div class="actions">
      <i class="icon-heart"></i>
      <i class="icon-plus"></i>
      <i class="icon-share-alt"></i>    
    </div>'))
    
    source = @template(@model.toJSON())
    this.setElement( $(source) )
    
    $(@el).css('opacity', "0")
    
    $('#content .pages').append( @el )
    
    @toolbar.render()
    
    $(@el).animate({ opacity: 1 }, 150)
    
  viewNext: (e)->
    target = this.next()
    if target
      console.log 'content', target
      
    e.preventDefault()
    
  next: ->
    content = App.stream.find (item)=> item.cid == "c" + (parseInt(@model.cid.match(/\d+$/)[0]) + 1)
    
    if content
      App.contentView = new App.ContentView( model: content )
      App.contentView.render()
    
    content
    