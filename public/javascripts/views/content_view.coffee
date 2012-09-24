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
    @view.on('fetch:next', this.fetchNext)
    @view.on('buffer:next', this.bufferNext)
    @view.on('buffer:prev', this.bufferPrev)
    # @view.on('slideTo:next', this.slideToNext)
    
  render: (model)->
    if model
      source = @template(model.toJSON())
      
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
  
  fetchNext: =>
    loading = $('#content .pages .loading')
    if content = this.next()
      loading.html($(this.render(content)).children()).addClass('current product').removeClass('loading').attr('data-handle', content.get('handle'))
    
  next: =>
    current = App.stream.find (item)=>
      item.get('handle') == ($('#content .pages .current').attr('data-handle') || @model.get('handle'))
    
    if !(content = App.stream.findNext(current))
      App.stream.fetchNext()
      
    else
      content
    
  prev: =>
    current = App.stream.find (item)=>
      item.get('handle') == $('#content .pages .current').attr('data-handle')
      
    content = App.stream.findPrev(current)
  
  bufferNext: =>
    target = this.next()
    if target instanceof Backbone.Model
      $('#content .pages').append($(this.render(target)))
              
  bufferPrev: =>
    $('#content .pages .padding').after(this.render(target)) if target = this.prev()
      
  # slideToNext: =>
    # update toolbar