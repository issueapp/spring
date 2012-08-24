# Application bootstrap
this.App ||= {
  standalone: window.navigator.standalone
  
  streams: [
    { title: "Top Content", "http://shop2.com/products.json?highres=true", default: true },
    { title: "Editors choices", "http://shop2.com/taylorluk/products.json?highres=true" },
    { title: "Mens", "http://shop2.com/interests/mens/products.json?highres=true" },
    { title: "Womens", "http://shop2.com/interests/womens/products.json?highres=true" },
    { title: "Womens", "http://shop2.com/interests/womens/products.json?highres=true" }
  ]
  
  init: ->
    this.router = new App.Router
    console.log "Router starting", Backbone.history.start({pushState: true, root: "/ipad/"})
    
    this.setLayout height: window.innerHeight, width: window.innerWidth, device: "ipad"

  setLayout: (dimension)->
    $('#touch-layout').remove()
    toolbar = { height:  $('nav.toolbar').height() }

    css = "
      .page { 
        width: #{dimension.width}px;
        height: #{dimension.height - toolbar.height}px;
      }\n

      div[role=main] {
      margin-top: #{toolbar.height}px !important;
      }"
    
    style = document.createElement('style')
    style.type = 'text/css'
    style.id = "touch-layout"
    
    if style.styleSheet
      style.styleSheet.cssText = css
    else
      style.appendChild(document.createTextNode(css));
    
    $(document.body).append(style)
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
      App.stream.url = "http://shop2.com/taylorluk/products.json?highres=true&sort=created_at"
      
      App.stream.fetch({ dataType: "jsonp" })
    else
      App.streamView.render()
    
  content: (handle) ->
    $(App.streamView.el).css('visibility', 'hidden')
    
    content = App.stream.find (item)-> item.get('handle') == handle
    App.contentView = new App.ContentView( model: content )
    App.contentView.render()
    
    console.log(content)
    