Environment = {
  host: if /localhost/.test window.location.host
          window.location.host
        else
          window.location.host.split(".").slice(-2).join(".")

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
    $('a[rel="app"]').live "click", (e) ->
      # unless @silentClick
      link = $(e.currentTarget).attr('href')
      App.router.navigate(link, { trigger: true })

      e.preventDefault()
      false
    
    this.layout = new App.Layout
    this.router = new App.Router
    Backbone.history.start({ pushState: true })
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
    App.toolbar.menu()
    $('#discover').hide()
    url = ""
    
    switch type
      when "users"
        url = "http://shop2.com/#{handle}/items.json"
      when "sites"
        url = "http://shop2.com/sites/#{handle}/items.json"
      when "interests"
        url = "http://shop2.com/interests/#{handle}.json"
    
    if App.stream.title != handle
      title = handle
      this.resetView(url, title)
    else
      this.backToStream()

  filter: (type)->
    url = App.stream.url
    title = App.stream.title
    this.resetView(url, title, type)

  home: ->
    $('#discover').hide()
    
    if !App.stream || App.streamView.title != App.streams.top_content.title
      url = App.streams.top_content.url
      title = App.streams.top_content.title
      this.resetView(url, title)
    else
      this.backToStream()

  discover: ->
    App.discover = new App.DiscoverView
    # App.discover.show()
    $('#discover').show()

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
      App.toolbar.actionsBtn = false
      App.toolbar.backBtn = false
      App.toolbar.typeBtn = true
      App.toolbar.title = title
      App.toolbar.render()

    # $('div.landing').hide() if $.fn.cookie('seenLandingPage') == "1"
    $('#sections .pages').addClass('horizontal')
    $('#content .pages').html('')
    $(document).off('keydown')

    spinner = new Spinner().spin()
    $('#sections').append(spinner.el)

    App.menu ||= new App.MenuView
    App.toolbar ||= new App.Toolbar

    App.stream = new App.StreamCollection
    App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream, title: title, newChannel: true })


    if type != undefined
      App.stream.url = url.replace(/\.json(\?.*)/, '.json') + "?sort=published_at&type=" + type

    else
      App.stream.url = url + "?sort=published_at"

    App.stream.title = title
    App.stream.fetch({ dataType: "jsonp" })

  backToStream: ->
    App.streamView.$el.animate({opacity: 1}, 150)
    App.toolbar.actionsBtn = false
    App.toolbar.backBtn = false
    App.toolbar.typeBtn = true
    App.toolbar.render()
