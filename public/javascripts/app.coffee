# Application bootstrap
this.App ||= {
  standalone: window.navigator.standalone

  streams: [
    { title: "Top Content", "http://shop2.com/items.json", default: true },
    { title: "Editors choices", "http://shop2.com/taylorluk/items.json" },
    { title: "Mens", "http://shop2.com/interests/mens/items.json" },
    { title: "Womens", "http://shop2.com/interests/womens/items.json" }
  ]

  init: ->
    this.layout = new App.Layout
    this.router = new App.Router
    Backbone.history.start({pushState: true, root: "/stream/"})
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

    "interests/:handle": "products"
    "products/:handle": "content"
    ":name/products": "stream"

  stream: (name)->
    if App.stream.owner != name
      $('#sections .pages').removeAttr("style")
      $('#sections .padding').width(0)
      $('#sections .pages').html('')

      spinner = new Spinner().spin()
      $('#sections').append(spinner.el)

      App.router.navigate("#{name}/products", { trigger: true })
      App.stream = new App.StreamCollection
      App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream })

      App.stream.url = "http://shop2.com/#{name}/items.json?sort=created_at"
      App.stream.title = "#{name}'s favourites"
      App.stream.owner = "#{name}"
      App.stream.fetch({ dataType: "jsonp" })
    else
      $(App.streamView.el).animate({ opacity: 1}, 150)

  products: (handle)->
    if App.stream.title != handle
      $('#sections .pages').removeAttr("style")
      $('#sections .padding').width(0)
      $('#sections .pages').html('')
      $('#content .pages').html('')

      spinner = new Spinner().spin()
      $('#sections').append(spinner.el)

      App.router.navigate("interests/#{handle}", { trigger: true })
      App.stream = new App.StreamCollection
      App.streamView = new App.StreamView({ el: '#sections .pages', layout: App.layout, collection: App.stream })

      App.stream.url = "http://shop2.com/interests/#{handle}.json"
      App.stream.title = handle
      App.stream.fetch({ dataType: "jsonp" })
    else
      $(App.streamView.el).animate({ opacity: 1}, 150)

  home: ->
    App.menu ||= new App.MenuView
    App.stream ||= new App.StreamCollection

    pages = $('#sections .swipe-paging')
    isMobile = this.isMobile()

    if isMobile
      App.listView ||= new App.ListView({ el: '#sections .swipe-paging', collection: App.stream })
    else
      pages.addClass('horizontal')
      App.streamView ||= new App.StreamView({ el: '#sections .swipe-paging', layout: App.layout, collection: App.stream })

    if App.contentView
      $(App.streamView.el).animate({ opacity: 1}, 150)

      $('#content .swipe-paging').html('')

    if App.stream.length == 0
      App.stream.url = "http://shop2.com/taylorluk/items.json?sort=created_at"
      App.stream.title = "Taylorluk's favourites"
      App.stream.fetch({ dataType: "jsonp" })

    else if isMobile
      App.listView.render()
    else
      App.streamView.render()

  content: (handle) ->
    $(App.streamView.el).css('opacity', "0")
    content = App.stream.find (item)-> item.get('handle') == handle

    App.contentView ||= new App.ContentView
    # App.contentView.view.offset = 0
    App.contentView.model = content
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

    # ismobile
    false
