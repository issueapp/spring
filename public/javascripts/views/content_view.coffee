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
  el: "#content .pages"
  
  template: Mustache.compile($('#product_tpl').html())
  
  initialize: ->
    @toolbar = new App.Toolbar
    this.render()
    $('#content .pages').append('<article class="page loading">Loading...</article>')
    
    @view = new App.SwipeView
    @view.on('fetch:next', this.viewNext)
    # @view.on('buffer:next', this.bufferNext)
    
  render: (model)->
    if model
      source = @template(model.toJSON())
      $('#content .pages').append( $(source) )
      
    else
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
    
    this
  
  viewNext: =>
    loading = $('#content .pages .loading')
    this.next()
    target = $('#content .pages .page').last()
    console.log 'target', target
    
    if target
      loading.html($(target).children())
      loading.removeClass('loading').addClass('product')
  
  next: =>
    content = App.stream.find (item)=> item.cid == "c" + (parseInt(@model.cid.match(/\d+$/)[0]) + 1)
    
    if content
      console.log 'next render', this.render(content)
    
    console.log 'next', @el
    @el
    
  bufferNext: =>
    page = this.next()
    