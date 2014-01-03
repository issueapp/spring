
# Layout
# 
# Issue layout manager
#
# [role=main]       - App container
# .stream.paging    - Stream container
#
Layout = {

  container: null
  orientation: null
  landscape: null
  portrait: null

  pageSize: { height: 0, width: 0 }
  viewport: { height: 0, width: 0 }

  # Refresh
  #
  # Refreshes application layout on orientation change
  refresh: ->
    # Previous viewport
    previous = {
      height: @viewport.height,
      width: @viewport.width
    }

    this.detectLayout()
    this.updateLayout()

    this.changeOrientation()

    # Find page dimension
    this.detectImageSizes()

    # Update Stream UI
    page = $('.stream.page:not(.template)')
    @pageSize = {
      height: page.height(),
      width: page.width()
    }

    # Stream#updatePadding
    this.updatePadding()

    # Update content UI
    this.updateContentWidth()

    # Update scroll pos
    if @support.swipe == "horizontal"
      offsetX = @scrollTarget[0].scrollLeft || @scrollTarget[0].scrollX
      pages = offsetX / previous.width

      @scrollTarget[0].scrollTo( pages * @viewport.width, 0) if offsetX > 0
    else
      offsetY = @scrollTarget[0].scrollTop || @scrollTarget[0].scrollY
      pages = offsetY / previous.height

      @scrollTarget[0].scrollTo(0, pages * @viewport.height) if offsetY > 0

  # Detect Layout
  #   set @support.swipe direction
  #   set @orientation
  #   set @viewport height & width
  #   hide tablet & mobile safari address bar
  detectLayout: ->

    if navigator.userAgent.match(/(iPhone|iPod)/)
      # NOTE: Temporary fix to support app.io ipad detection
      @support.swipe = if window.screen.height > 568 then "horizontal" else "vertical"

    else if !!navigator.userAgent.match(/iPad/)
      @support.swipe = "horizontal"

    window.scrollTo(0, 1) if @support.swipe && !@support.webview

    # Support horizontal swipe
    if @support.swipe == "horizontal"
      $('[role=main]').addClass("horizontal")
    else
      $('[role=main]').addClass("vertical")

    if window.orientation
      @orientation = if window.orientation % 180 == 0 then 'portrait' else 'landscape'
    else
      @orientation = "portrait"

    @landscape = @orientation == "landscape"
    @portraite = @orientation == "portrait"

    # Refresh view port
    if @support.swipe
      @viewport.width = Math.max(320, window.innerWidth)
      @viewport.height = window.innerHeight #- $('header.toolbar').height()
    else
      @viewport.width = Math.min(1024, window.innerWidth)
      @viewport.height = Math.min(704, window.innerHeight)

  # Calcualte page layout
  updateLayout: ->
    if @support.swipe
      css = "
        #sections { max-width: #{@viewport.width}px }\n
        article.two-column.paginate .body { width: #{@viewport.width}px }\n
        article.two-column .cover-area { width: #{@viewport.width / 2}px }\n

        [role=main] .page {\n
          width: #{@viewport.width}px;
          height: #{@viewport.height}px;
        }\n
      "
    else
      css = "
        article.two-column .cover-area { width: #{@viewport.width / 2}px }\n
        article.two-column.paginate .body { width: #{@viewport.width }px }\n
        \n
        [role=main] .page {
          height: #{@viewport.height}px;
          width: 100%;
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
    $(document.head).append(style)

    # console.log("[Layout] Set layout size")

  # Change Orientation
  #   row v-half   =>  col half
  #
  #   item third   =>  item v-third
  #   item half    =>  item v-half
  #   item third-2 =>  item v-third-2
  changeOrientation: (new_pages)->
    pages = new_pages || $('.stream.page')

    # current orientation
    if window.orientation % 180 == 0 || @support.swipe == "vertical"
      orientation = 'vertical'
    else
      orientation = 'horizontal'

    from = pages.data('orientation') || @support.swipe

    if from == orientation
      return
    else
      switchLandscape = orientation == 'horizontal'

    # console.log("[change orientation] from:#{from} to: #{orientation} #{switchLandscape}")

    # Landscape     vs. Portrait
    mapping = {
      "row v-half"    : "col half",
      "item third"    : "item v-third",
      "item half"     : "item v-half",
      "item third-2"  : "item v-third-2",
      "item split"    : "item no-split"
    }

    for className, toClass of mapping
      if switchLandscape
        [className, toClass] = [toClass, className]

      pages.find(".#{className.split(" ").join(".")}").removeClass(className).addClass(toClass)

    pages.data('orientation', orientation)

    pages

  # Use browser to calculate the size of image container
  detectImageSizes: ->
    @imageSizes = {} unless @imageSizes?
    template = $('.page.template')

    if this.landscape
      width = screen.width
      height = screen.height

      if height > width
        [width, height] = [height, width]

    else
      width = window.innerWidth
      height = window.innerHeight

    template.show()

    template.find('.item .image').each ->
      size_class = $.trim this.parentNode.className.replace('item photo', '')

      App.imageSizes[size_class] = {
        width: $(this).width(),
        height: $(this).height()
      }

    template.hide()

    # console.log('[issue.coffee] image sizes detected:', @imageSizes)

  # Update content width for 2-col layout
  updateContentWidth: ->
    two_col_page = $('.two-column').removeClass('paginate')

    if two_col_page.length > 0

      # detect if content overflows then
      if content_overflow = two_col_page[0].scrollHeight > (two_col_page[0].offsetHeight + 20)
        two_col_page.css('width', '')
        two_col_page.addClass('paginate') if content_overflow

        setTimeout =>
          # console.log("SET Content width", content_overflow , App.viewport.width, $('.two-column')[0].scrollWidth)

          width = Math.ceil( two_col_page[0].scrollWidth / App.viewport.width ) * App.viewport.width
          two_col_page.width(width)
        , 200

  # Layout related
  scrollTop: (element, duration = 200)->
    element = $(element)[0] || window
    scrollTop = $(element).scrollTop()
    return unless scrollTop

    (animloop = ->
      if scrollTop > 0
        step = (scrollTop / 200) * 16
        step = 50  if step < 50

        scrollTop = scrollTop - step
        scrollTop = 0  if scrollTop < 0

        element.scrollTop = scrollTop

        requestAnimationFrame animloop
      else
        element.scrollTop = 0
    )()

  overlay: (toggle)->
    if toggle == false
      $('.overlay').false()
      $(document.body).toggleClass('locked', false)
    else
      $('.overlay').show()
      $(document.body).toggleClass('locked', true)
}

App.extend Layout
