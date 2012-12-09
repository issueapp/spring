# Application bootstrap
this.App ||= {
  standalone: window.navigator.standalone

  streams: {
    top_content: {
      title: "Top Content"
      url: "http://shop2.com/taylorluk/items.json"
      default: true
    }
    editors_choices: {
      title: "Editors choices"
      url: "http://shop2.com/taylorluk/items.json"
    }
    mens: {
      title: "Mens"
      url: "http://shop2.com/interests/mens/items.json"
    }
    womens: {
      title: "Womens"
      url: "http://shop2.com/interests/womens/items.json"
    }
  }

  init: ->
    this.layout = new App.Layout
    this.router = new App.Router
    Backbone.history.start({ pushState: true, root: "/stream/" })
}

class App.Layout extends Backbone.View

  initialize: ->
    this.resize()

    $(window).on "orientationchange", => this.resize()
    $(window).on "resize", => this.resize()

  resize: ->
    dimension = {
      width:  window.innerWidth
      height: window.innerHeight
    }

    @viewport = $('#sections').width()
    toolbar   = { height: $('header.toolbar').height() }

    css = "
      body {
        height: #{dimension.height}px;
      }\n

      .page {
        width: #{dimension.width}px;
        height: #{dimension.height - toolbar.height}px;
      }\n

      .landing {
        width: #{dimension.width}px;
      }\n

      .landing .welcome {
       width: #{dimension.width}px;
      }
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
    "stream":           "home"
    "section":          "home"
    "interests/:handle": "items"
    "items/:handle": "content"
    ":name/items": "stream"

  stream: (name)->
    if App.stream.title != (name + "'s Favorites")
      url = "http://shop2.com/#{name}/items.json"
      title = name + "'s Favorites"
      this.resetView(url, title)

    else
      this.backToStream()

  items: (handle)->
    if App.stream.title != handle
      url = "http://shop2.com/interests/#{handle}.json"
      title = handle
      this.resetView(url, title)

    else
      this.backToStream()

  home: ->
    if !App.stream || App.streamView.title != App.streams.top_content.title
      url = App.streams.top_content.url
      title = App.streams.top_content.title
      this.resetView(url, title)

    else
      this.backToStream()

  content: (handle) ->
    App.streamView.$el.css('opacity', '0')
    content = App.stream.find (item)-> item.get('handle') == handle
    App.contentView ||= new App.ContentView

    App.contentView.resetAttrs()
    App.contentView.model = content
    App.contentView.render()

  resetView: (url, title)->
    if App.toolbar
      App.toolbar.actionsBtn = false
      App.toolbar.backBtn = false
      App.toolbar.title = title
      App.toolbar.render()

    $('#sections .pages').addClass('horizontal')
    $('#content .pages').html('')
    $(document).off('keydown')

    spinner = new Spinner().spin()
    $('#sections').append(spinner.el)

    App.menu ||= new App.MenuView
    App.toolbar ||= new App.Toolbar

    App.stream = new App.StreamCollection
    App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream, title: title })

    App.stream.url = url + "?sort=created_at"
    App.stream.title = title
    App.stream.fetch({ dataType: "jsonp" })

  backToStream: ->
    App.streamView.$el.animate({opacity: 1}, 150)
    App.toolbar.actionsBtn = false
    App.toolbar.backBtn = false
    App.toolbar.render()

  # isMobile: ->
  #   uagent = navigator.userAgent.toLowerCase()
  #   ismobile = false
  #
  #   list = [
  #       "midp","240x320","blackberry","netfront","nokia","panasonic",
  #       "portalmmm","sharp","sie-","sonyericsson","symbian",
  #       "windows ce","benq","mda","mot-","opera mini",
  #       "philips","pocket pc","sagem","samsung","sda",
  #       "sgh-","vodafone","xda","palm","iphone",
  #       "ipod","android"
  #     ]
  #
  #   list.forEach (item)->
  #     if uagent.indexOf(item) != -1
  #       ismobile = true
  #
  #   # ismobile
  #   false
