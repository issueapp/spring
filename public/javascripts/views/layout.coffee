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
        height: #{dimension.height}px;
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

