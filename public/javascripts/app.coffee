# Application bootstrap
this.App ||= {
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
}

class App.Router extends Backbone.Router
  routes:
    "stream":                     "home"
    "section":                    "home"
    
    "signup":                     "signup"
    
    "items/:handle":              "content"

    "discover":                   "discover"
    "discover/:category":         "discover"

    ":type/:handle":              "channel"

  initialize: (options)->
    this.route(/.*\?type=(\w+)/, "filter")

  signup: ->
    # App.toolbar.hide()
    $('.landing').hide()

    $('#signup').show()

  home: ->
    $('.landing').hide()
        
    App.stream.title = "My Edition"
    this.channel("stream")

  # View a channel in a stream format
  channel: (type, handle)->
    
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

  issue: ->


  content: (handle) ->
    
    App.streamView.hide()
    App.contentView.show()

    # Might need to delay rendering when page is loading
    renderer = (c)->
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
    "http://shop2.com/#{path}.json"

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
      App.stream.title = title
      # This is probably duplicate
      App.streamView.show()

  backToStream: ->
    App.contentView.hide()

    App.streamView.show()

