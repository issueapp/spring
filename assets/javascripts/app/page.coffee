class PageView extends Backbone.View
  
  el: 'article.page'
  
  initialize: ->
    @container = $(window)
    
    @hotspot = new Hotspot(el: ".hotspot")
    App.updateContentWidth()
    
  render: ->

    
  next: ->
    scrollLeft = @container.scrollLeft()
    
    this.$el.css('opacity', '0')
    
    window.scrollTo( scrollLeft + App.viewport.width, 0)
    
    this.$el.animate({'opacity':1}, 0.3, 'ease-out')

    
  prev: ->
    scrollLeft = @container.scrollLeft()
    
    # this.$el.css('-webkit-animation', 'none')
    this.$el.css('opacity', '0')
    
    window.scrollTo( Math.max(0, scrollLeft - App.viewport.width) , 0)
    
    this.$el.animate({'opacity':1}, 0.3, 'ease-out')
  
  canScroll: (dir)->
    if dir == 'left'
      @container.scrollLeft() >= App.viewport.width
    else
      @container.scrollLeft() < this.$el.width() - App.viewport.width
  
  back: ->
  
  
# Export to global
this.PageView = PageView