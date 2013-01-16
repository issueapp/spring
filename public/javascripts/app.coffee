Environment = {
  host: "shop2.com"
    # if /localhost/.test window.location.host
    #   "shop2.com"
    # else
    #   window.location.host.split(".").slice(-2).join(".")
}

# Application bootstrap
this.App ||= {
  standalone: window.navigator.standalone

  streams: {
    top_content: {
      title: "Top Content"
      url: "http://#{Environment.host}/taylorluk/items.json"
      default: true
    }
    editors_choices: {
      title: "Editors choices"
      url: "http://#{Environment.host}/taylorluk/items.json"
    }
    mens: {
      title: "Mens"
      url: "http://#{Environment.host}/interests/mens/items.json"
    }
    womens: {
      title: "Womens"
      url: "http://#{Environment.host}/interests/womens/items.json"
    }
  }


  init: ->

    # All link should be internal /!#/path
    $('a:not([rel="external"])').live "click", (e) ->
      # unless @silentClick
      link = $(e.currentTarget).attr('href')
      App.router.navigate(link, { trigger: true })

      e.preventDefault()
      false

    @layout = new App.Layout
    @router = new App.Router

    @menu = new App.MenuView
    @toolbar = new App.Toolbar

    @stream = new App.StreamCollection
    @streamView = new App.StreamView( el: '#sections .pages', layout: @layout, collection: @stream )

    Backbone.history.start()

    if Backbone.history.fragment
      $('.landing').hide()
    else
      $('.landing').css('opacity', '1')
}

class App.Router extends Backbone.Router
  routes:
    "stream":           "home"
    "section":          "home"
    "items/:handle": "content"
    "discover": "discover"
    ":type/:handle": "channel"

  initialize: (options)->
    this.route(/.*\?type=(\w+)/, "filter")

  # View a channel in a stream format
  channel: (type, handle)->
    # toggle toolbar
    App.menu.toggle(false)
    $('#discover').hide()
    url = ""

    switch type
      when "users"
        url = "http://shop2.com/#{handle}/items.json"
      when "sites"
        url = "http://shop2.com/sites/#{handle}/items.json"
      when "interests"
        url = "http://shop2.com/interests/#{handle}.json"


    if !App.stream || App.stream.title != handle
      title = handle
      this.resetView(url, title)
    else
      this.backToStream()

  filter: (type)->
    url = App.stream.url
    title = App.stream.title
    this.resetView(url, title, type)

  home: ->
    $('.landing').hide()
    $('#discover').hide()
    if !App.stream || App.streamView.title != App.streams.top_content.title
      url = App.streams.top_content.url
      title = App.streams.top_content.title
      this.resetView(url, title)
    else
      this.backToStream()

  discover: ->
    # App.discover = new App.DiscoverView
    $('#discover').show()

    $('.landing').hide()
    # this.resetView()
    App.menu.toggle(true)

  content: (handle) ->
    App.streamView.$el.css('opacity', '0')
    content = App.stream.find (item)-> item.get('handle') == handle
    App.contentView ||= new App.ContentView

    App.contentView.resetAttrs()
    App.contentView.model = content
    App.contentView.render()

  resetView: (url, title, type)->
    $('#discover').hide()

    if App.toolbar
      App.toolbar.render(title: title, typeBtn: false, backBtn: false, actionsBtn: false)

    # $('div.landing').hide() if $.fn.cookie('seenLandingPage') == "1"
    $('#sections .pages').addClass('horizontal')
    $('#content .pages').html('')
    $(document).off('keydown')

    # Target resource url
    if type != undefined
      url = url.replace(/\.json(\?.*)/, '.json') + "?sort=published_at&type=" + type
    else
      url = url + "?sort=published_at"

    # Only fetch new stream content when URL is different
    if url && url != App.stream.url
      spinner = new Spinner().spin()
      $('#sections').append(spinner.el)

      App.stream = new App.StreamCollection
      App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream, title: title, newChannel: true })

      App.stream.url = url
      App.stream.title = title

      App.stream.fetch({ dataType: "jsonp" })
    else
      # This is probably duplicate
      App.streamView.$el.animate({opacity: 1}, 150)

  backToStream: ->
    App.toolbar.render(actionsBtn: false, backBtn: false, typeBtn: true, channelBtn: true, followBtn: true)
    App.streamView.$el.animate({opacity: 1}, 150)
