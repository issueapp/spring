
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
  viewport: { height: 0, width: 0, maxHeight: false, maxWidth: false}

  # Refresh
  #
  # Refreshes application layout on orientation change
  refresh: ->
    # Previous viewport
    previous = {
      orientation: @orientation,
      height: @viewport.height,
      width: @viewport.width
    }

    # change orientation
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

    # Update content UI    #
    this.updateContentWidth()

    # Trigger layout refresh event with previous dimension
    App.trigger("layout:refresh", previous: previous)

    # TODO: Move to stream
    # Stream#updatePadding
    #this.updatePadding()
    # Update scroll pos
    # if @support.swipe == "horizontal"
    #   offsetX = @scrollTarget[0].scrollLeft || @scrollTarget[0].scrollX
    #   pages = offsetX / previous.width
    #
    #   @scrollTarget[0].scrollTo( pages * @viewport.width, 0) if offsetX > 0
    # else
    #   offsetY = @scrollTarget[0].scrollTop || @scrollTarget[0].scrollY
    #   pages = offsetY / previous.height
    #
    #   @scrollTarget[0].scrollTo(0, pages * @viewport.height) if offsetY > 0


  # Detect Layout
  #   set @support.swipe direction
  #   set @orientation
  #   set @viewport height & width
  #   hide tablet & mobile safari address bar
  detectLayout: ->
    container = $('[role=main]')
    
    # flag embed
    document.documentElement.className += " embed" unless @support.embed

    # detect touch event
    document.documentElement.className += " no-touch" unless @support.touch
    
    # Set screen resolution cookie
    document.cookie='resolution='+Math.max(screen.width,screen.height)+'; path=/'


    if navigator.userAgent.match(/(iPhone|iPod)/)
      # NOTE: Temporary fix to support app.io ipad detection
      @support.swipe = if window.screen.height > 568 then "horizontal" else "vertical"

    else if !!navigator.userAgent.match(/iPad/)
      @support.swipe = "horizontal"

    window.scrollTo(0, 1) if @support.swipe && !@support.webview

    # Support horizontal swipe
    if @support.swipe == "horizontal" || window.innerHeight < window.innerWidth
      container.removeClass("portrait").addClass("landscape")
    else
      container.removeClass("landscape").addClass("portrait")

    if window.orientation
      @orientation = if window.orientation % 180 == 0 then 'portrait' else 'landscape'
    else
      @orientation = "portrait"

    @landscape = @orientation == "landscape"
    @portraite = @orientation == "portrait"

    # Refresh view port
    if @support.swipe
      @viewport.width = Math.max(320, container.width())
      @viewport.height = container.height() #- $('header.toolbar').height()
    else
      @viewport.width = if @viewport.maxWidth then Math.min(@viewport.maxWidth, container.width() ) else container.width()
      @viewport.height = if @viewport.maxHeight then Math.min(@viewport.maxHeight, container.height() ) else container.height()


    # Notify layout detected and propagate layout object
    #
    App.trigger("layout:detect", { orientation: @orientation, height: @viewport.height, width: @viewport.width  })

  # Calcualte page layout
  updateLayout: ->

    if @support.swipe
      css = "
      @media only screen and (min-width: 768px) {\n
        #sections { max-width: #{@viewport.width}px }\n

        article.paginate .content { width: #{@viewport.width}px }\n

        article.two-column .cover-area { width: #{@viewport.width / 2}px }\n
        article.three-column .cover-area { width: #{@viewport.width * 2 / 3}px }\n

        article.two-column.cover-right .cover-area { left: #{@viewport.width / 2}px }\n
        article.three-column.cover-right .cover-area { left: #{@viewport.width / 3}px }\n
      }\n

      @media only screen and (min-width: 768px) and (orientation: landscape) {\n
        article.two-column.no-image.has-product.cover-left .content { margin-left: #{@viewport.width / 2}px }\n
      }\n

      [role=main] .page {\n
        width: #{@viewport.width}px;
        height: #{@viewport.height}px;
      }\n
      "
    else
      css = "
      @media only screen and (min-width: 768px) {\n
        #sections { max-width: #{@viewport.width}px }\n

        article.paginate .content { width: #{@viewport.width}px }\n

        article.two-column .cover-area { width: #{@viewport.width / 2}px }\n
        article.three-column .cover-area { width: #{@viewport.width * 2 / 3}px }\n

        article.two-column.cover-right .cover-area { left: #{@viewport.width / 2}px }\n
        article.three-column.cover-right .cover-area { left: #{@viewport.width / 3}px }\n
      }\n

      @media only screen and (min-width: 768px) and (orientation: landscape) {\n
        article.two-column.no-image.has-product.cover-left .content { margin-left: #{@viewport.width / 2}px }\n
      }\n

      [role=main] .page {\n
        width: #{@viewport.width}px;
        height: #{@viewport.height}px;
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
    paginate_page = $('.page.paginate').removeClass('paginate')

    if paginate_page.length > 0
      content_overflow = paginate_page[0].scrollHeight > (paginate_page[0].offsetHeight + 20)

      # detect if content overflows then
      if content_overflow
        paginate_page.css('width', '')
        paginate_page.addClass('paginate') if content_overflow

        setTimeout =>
          width = Math.ceil( paginate_page[0].scrollWidth / App.viewport.width ) * App.viewport.width
          paginate_page.width(width)
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
