# Application bootstrap
this.App ||= {
  standalone: window.navigator.standalone
  touch: !!('ontouchstart' in window)

  init: ->
    @layout = new App.Layout
    @router = new App.Router
    @discover = new App.DiscoverMenu

    @menu = new App.MenuView
    @toolbar = new App.Toolbar

    @stream = new App.StreamCollection
    @streamView = new App.StreamView( el: '#sections .pages', layout: @layout, collection: @stream )
    @contentView ||= new App.ContentView

    Backbone.history.start()

    if Backbone.history.fragment
      $('.landing').hide()
    else
      $('.landing').css('opacity', '1')

    # All link should be internal /!#/path # unless @silentClick
    $('a:not([rel="external"])').live "click", (e) ->
      link = $(e.currentTarget).attr('href')
      App.router.navigate(link, { trigger: true })
      e.preventDefault()
      false
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
    App.toolbar.hide()
    $('.landing').hide()

    $('#signup').show()

  home: ->
    $('.landing').hide()
    
    this.channel("stream")

  # View a channel in a stream format
  channel: (type, handle)->
    
    App.menu.toggle(false)
    App.contentView.clear()
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

    # alert(Backbone.history.fragment)

    # App.discover = new App.DiscoverView

    App.discover.collection = App.channels
    App.discover.render(category)
    App.menu.render()

  issue: ->


  content: (handle) ->
    App.streamView.hide()
    App.contentView.show()

    # Might need to delay rendering when page is loading
    renderer = (c)->
      
      App.contentView.resetAttrs()
      App.contentView.model = c

      App.contentView.render()

    # fetch item from collection
    if App.stream.length > 0
      content = App.stream.find (e)-> e.get('handle') == handle
      console.log "From collection", handle, content
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

    # reset toolbar to default states.
    if App.toolbar
      App.toolbar.render(title: title, typeBtn: false, backBtn: false, actionsBtn: false)

      # reset filter dropdown view-all to active when swithcing channels
    if url && url != App.stream.url
      dropdown = $('#sections #filter-dropdown')
      dropdown.find('.active').removeClass('active')
      dropdown.find('.view-all').addClass('active')

    # Section views reset
    $('#sections .pages').addClass('horizontal')
    $('#content .pages').html('')

    # Shouldn't new render replace it?
    $('#sections #noContent').remove()

    $(document).off('keydown')

    # TODO: this code block like fetching the stream again renderStream(url)
    # Only fetch new stream content when URL is different
    if url && url != App.stream.url
      App.stream = new App.StreamCollection
      App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream, title: title, newChannel: true })

      App.stream.url = url
      App.stream.title = title

      spinner = new Spinner().spin()
      $('#sections').append(spinner.el)

      App.stream.fetch({ dataType: "jsonp" })
    else
      # This is probably duplicate
      App.streamView.show()

  backToStream: ->
    App.toolbar.render(actionsBtn: false, backBtn: false, typeBtn: true, channelBtn: true, followBtn: true)
    $('#content .pages').html('')

    App.streamView.show()

