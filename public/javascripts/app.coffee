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
    this.layout = new App.Layout

    this.router = new App.Router
    console.log "Router starting", Backbone.history.start({pushState: true, root: "/ipad/"})
    
}

class App.Layout extends Backbone.View
  
  initialize: ->
    this.resize()
    
    $(window).on "orientationchange", => this.resize()
    $(window).on "resize", => this.resize()
  
  resize: ->
    dimension = {
      width: window.innerWidth
      height: window.innerHeight
    }
    
    @viewport = $('#sections').width()
    toolbar = { height:  $('header.toolbar').height() }

    css = "
      .page { 
        width: #{dimension.width}px;
        height: #{dimension.height - toolbar.height}px;
      }\n
      "
    
    style = document.createElement('style')
    style.type = 'text/css'
    style.id = "touch-layout"
    
    if style.styleSheet
      style.styleSheet.cssText = css
    else
      style.appendChild(document.createTextNode(css));
    
    # Remove and reset the style
    $('#touch-layout').remove()
    $(document.body).append(style)

    # main view
    if App.streamView
      App.streamView.onResize()
    

class App.Router extends Backbone.Router
  routes:
    "ipad":             "home"
    "section":          "home"
    "products/:handle": "content"
  
  home: ->
    App.stream ||= new App.StreamCollection
    pages = $('#sections .pages')
    isMobile = this.isMobile()
    
    if isMobile
      # pages.addClass('vertical')
      App.listView ||= new App.ListView({ el: '#sections .pages', collection: App.stream })
    else
      pages.addClass('horizontal')
      App.streamView ||= new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream })
    
    if App.contentView
      $(App.streamView.el).animate({ opacity: 1}, 150)
      
      $('#content').html('')
    
    if App.stream.length == 0
      App.stream.url = "http://shop2.com/taylorluk/products.json?highres=true&sort=created_at"
      App.stream.fetch({ dataType: "jsonp" })
    else if isMobile
      App.listView.render()
    else
      App.streamView.render()
    
  content: (handle) ->
    $(App.streamView.el).css('opacity', "0")
    
    content = App.stream.find (item)-> item.get('handle') == handle
    App.contentView = new App.ContentView( model: content )
    App.contentView.render()
  
  isMobile: ->
    uagent = navigator.userAgent.toLowerCase()
    ismobile = false
    
    list = [
        "midp","240x320","blackberry","netfront","nokia","panasonic",
        "portalmmm","sharp","sie-","sonyericsson","symbian",
        "windows ce","benq","mda","mot-","opera mini",
        "philips","pocket pc","sagem","samsung","sda",
        "sgh-","vodafone","xda","palm","iphone",
        "ipod","android"
      ]
    
    list.forEach (item)->
      if uagent.indexOf(item) != -1
        ismobile = true
    
    ismobile
    # true