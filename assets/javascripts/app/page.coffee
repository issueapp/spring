class PageView extends Backbone.View
  
  initialize: ->
    @hotspot = new Hotspot(el: ".hotspot")
    App.updateContentWidth()
    
  render: ->

    
  next: ->
  
  prev: ->
    
  back: ->
  
  
# Export to global
this.PageView = PageView