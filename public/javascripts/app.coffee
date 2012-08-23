# Application bootstrap
this.App ||= {
  init: ->
    this.router = new App.Router
    console.log "Router starting", Backbone.history.start({pushState: true, root: "/ipad/"})
}

class App.Router extends Backbone.Router
  routes:
    "ipad":         "home"
    "section":      "home"
    "products/:handle":      "content"
  
  home: ->
    console.log('backhome')
    App.stream ||= new App.StreamCollection
    App.streamView ||= new App.StreamView({ el: '#pages', collection: App.stream })
    
    if App.contentView
      $(App.streamView.el).css('visibility', 'visible')
      $('#content').html('')
    
    if App.stream.length == 0
      App.stream.url = "http://shop2.com/taylorluk/products.json?highres=true"
      
      App.stream.fetch({ dataType: "jsonp" })
    else
      App.streamView.render()
    
  content: (handle) ->
    $(App.streamView.el).css('visibility', 'hidden')
    
    content = App.stream.find (item)-> item.get('handle') == handle
    App.contentView = new App.ContentView( model: content )
    App.contentView.render()
    
    console.log(content)
    