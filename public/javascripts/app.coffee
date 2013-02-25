# Application bootstrap
this.App || = {}

_.extend(App, {
  standalone: window.navigator.standalone
  touch: !!('ontouchstart' in window)

  init: ->
    @router = new App.Router

    @layout = new App.Layout
    @discover = new App.DiscoverMenu

    @menu = new App.MenuView

    @stream = new App.StreamCollection
    @streamView = new App.StreamView( layout: @layout, model: @stream )
    @contentView ||= new App.ContentView
    @popover = new App.PopoverView

    Backbone.history.start()

    if Backbone.history.fragment
      $('.landing').hide()
    else
      $('.landing').css('opacity', '1')

    $('a[rel="popover"]').live "click", (e)=>
      target = $(e.currentTarget)
      id = target.attr('href') # id => #filterDropdown
      return if !id

      dropdown = $(id)
      $('.popover:not('+id+'):visible').hide()

      if dropdown.length == 0
        method = id.replace('#', '') # method => filterDropdown
        @popover[method](target) if typeof @popover[method] == "function" # popover.filterDropdown(target)
        @popover.setElement('.popover')

      else
        dropdown.toggle()

      false

    # All link should be internal /!#/path # unless @silentClick
    $('a:not([rel="external"]):not([rel="popover"])').live "click", (e) =>
      link = $(e.currentTarget).attr('href')
      App.router.navigate(link, { trigger: true }) if link != '#' && link != ''

      false

    $("body").live "click touchend", (e)=>
      if $('.popover:visible').length > 0 && $(e.target).attr('rel') != 'popover' && $(e.target).parent().attr('rel') != 'popover'
        setTimeout =>
          $('.popover:visible').hide()
        , 0
})

class App.Router extends Backbone.Router
  routes:
    "stream":                     "home"
    "issue":                      "issue"
    "signup":                     "signup"
    "gallery":                    "gallery"
    "gallery/:index":             "gallery"
    "items/:handle":              "content"

    "discover":                   "discover"
    "discover/:category":         "discover"

    ":type/:handle":              "channel"

  initialize: (options)->
    this.route(/.*\?type=(\w+)/, "filter")

  issue: ->
    App.gallery.close() if App.gallery
    App.menu.toggle(false)
    $('#issue').show()
    $('#discover').hide()
    App.streamView.hide()
    App.contentView.hide()
    $('.start-button').click => $("#issue .cover").hide()

    
    App.issue ||= new App.SwipeView(el: "#issue .swipe-paging", clearPage: false)
    
    $('#issue .toolbar').show();
    
    App.issue.on 'slideTo',   (page)=>
      $(document.body).toggleClass("dark-theme", $(page).is('.dark'))

  gallery: ()->
    App.gallery = new App.GalleryView($('#issue .current.page .gallery a'))
    
    App.gallery.on "open", (page)=>
      $(document.body).toggleClass("dark-theme", $(page).is('.dark'))
      $('#issue .toolbar').hide()
      
    App.gallery.on "close", =>
      $('#issue .toolbar').show()

    App.gallery.render()
    
  signup: ->
    $('#issue').hide()
    # App.toolbar.hide()
    $('.landing').hide()

    $('#signup').show()

  home: ->
    $('.landing').hide()
        
    App.stream.title = "My Edition"
    this.channel("stream")

  # View a channel in a stream format
  channel: (type, handle)->
    $('.landing').hide()
    $('#issue').hide()

    App.menu.toggle(false)
    App.contentView.hide()

    $('#discover').hide()
    $('#signup').hide()

    # Default to stream stream url
    url = switch type
      when "users"
        this.url_for("#{handle}/items")
      when "sites"
        this.url_for("sites/#{handle}/items")
      when "interests"
        this.url_for("interests/#{handle}/items")
      else
        this.url_for("taylorluk/items")

    if !App.stream || (App.stream && App.stream.url != url)
      this.resetView(url, handle)

    else
      this.backToStream()

  filter: (type)->
    if type != undefined
      url = App.stream.url.replace(/\.json(\?.*)/, '.json') + "?sort=published_at&type=" + type
    else
      url = App.stream.url + "?sort=published_at"
    title = App.stream.title

    this.resetView(url, title)

  discover: (category)->
    $('.landing').hide()
    
    App.discover.collection = App.channels
    App.discover.render(category)
    App.menu.render()

  content: (handle) ->
    # App.contentView.$('.pages').html("")
    
    App.streamView.hide()
    App.contentView.show()

    # Might need to delay rendering when page is loading
    renderer = (c)->
      console.log(c)
      App.contentView.reset()
      App.contentView.model = c
      App.contentView.render()

    # fetch item from collection
    if App.stream.length > 0
      content = App.stream.find (e)-> e.get('handle') == handle
      renderer(content)
    else
    # request a new item
      product = new Backbone.Model
      product.fetch({
        dataType: "jsonp", url: this.url_for("items/#{handle}"),
        success: (data)-> renderer(product)
      })

  url_for: (path)->
    host = App.api_host || "shop2.com"
    
    "http://#{host}/#{path}.json"

  # Set view to default state
  # This is a work around when we change between different view containers.
  resetView: (url, title, type)->
    $(document).off('keydown')

    # Update stream content when URL is different
    if url && url != App.stream.url
      # App.streamView = new App.StreamView({ layout: App.layout, model: App.stream, title: title })
      App.stream = new App.StreamCollection
      App.stream.url = url
      App.stream.title = title if title
      
      App.streamView.model = App.stream
      App.streamView.reset()
      # App.streamView.loading(true)
      App.stream.fetch({ dataType: "jsonp" })
    else
      App.streamView.title = title
      App.streamView.show()

  backToStream: ->
    App.contentView.hide()

    App.streamView.show()

