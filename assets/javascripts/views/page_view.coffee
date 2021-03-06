###
 Page contain multiple rows

  Example:

    [
      { title: 'a', image_height: 100, image_width: 100 },
      { title: 'b', image_height: 200, image_width: 100 }, // tall
      { title: 'c', image_height: 100, image_width: 200 }, // tall
    ]

    p = new Page([1,2,3,4,5])

    p.render
    div.page
      div.row [ 1 ]
      div.row [ 2 ]
      div.row [ 3 ]
###
class App.PageView extends Backbone.View
  # constructor: (width, height)->
  #   @width = width
  #   @height = height
  #   @limit = 3
  #   @products = products
  #   @rows = []
  #
  # fill: (products)->
  #
  # render: ->
  events:
    'click .item a.link': 'viewContent'
    # 'swipe .item a.link': 'silent'
    'orientationchange': 'changeOrientation'

  # <div class="image cover">
  #   <a class="link" href="/products/{{ handle }}">
  #     <img src="http://deyf8doogqx67.cloudfront.net{{ cdn_image_url }}">
  #   </a>
  # </div>

  # <a class="via user" href="">
  #   {{#author}}
  #   <img src="{{ image_url }}" width=16 height=16> <span class="action">Collected by</span> {{ name }}
  #   {{/author}}
  # </a>
  itemTemplate: Mustache.compile(
    '
    <a class="link" href="/items/{{ handle }}">
      <div class="image" data-original="{{ image_url }}" style="background-size: cover; background-image:url({{ image_url }}); background-position: center;">
      </div>
    </a>
    <figcaption class="info">
      <a class="link" href="/items/{{ handle }}">
        <h3 class="title">{{ title }}</h3>
      </a>
      
      <p class="description">{{ description }}</p>

      {{#site}}
      <a href="{{ path }}" class="via user">
        <!-- 
        <img alt="Profile_image?screen_name=nkechinjaka&amp;size=bigger" height="16" src="http://api.twitter.com/1/users/profile_image?screen_name=NkechiNjaka&amp;size=bigger" width="16">
        -->
        by {{ title }}
      </a>
      {{/site}}
    </figcaption>
    
    {{#price}}
      <a class="price">{{price}}</a>
    {{/price}}
    '
  )

  @templateIndex = -1
  #         5  4  3  4  5  3  4  5  4  3 items count
  @order = [0, 1, 3, 2, 0, 3, 2, 0, 2, 3]
  # until @order.length == 10
  #   @order.push Math.floor(Math.random() * $('script.section_tpl').length)

  @getTemplate = (data)=>
    if data.isMobile
      @section_tpl ||= $('script.mobile_tpl')
      @section_tpl.html()
    else
      @section_tpl ||= $('script.section_tpl')

      if data.method == 'append'
        if data.stream.changedDir
          @templateIndex += 2

        @templateIndex += 1
        @templateIndex = 0 if @templateIndex > 9
        @templateIndex = 3 if @templateIndex == 1 && $('#sections .page.rotatable').length == 3 && $('#sections .padding').css('width') == '0px'

      else
        if data.stream.changedDir
          @templateIndex -= 2
          @templateIndex = 10 if @templateIndex == 0

        @templateIndex -= 1
        @templateIndex = 9 if @templateIndex == -1
        @templateIndex = 8 if @templateIndex == -2
        @templateIndex = 7 if @templateIndex == -3

      index = @order[@templateIndex]
      @section_tpl.eq(index).html()

  initialize: (data)->
    @offset = null
    @items = []

    @page = $(App.PageView.getTemplate(data))

    # @fragment = $('#temp').html(App.PageView.getTemplate(data)).css('visibility', 'hidden')
    #
    # @page = $(@fragment.children().first())
    @limit = @page.find('.item').length
    @isMobile = data.isMobile

    if window.orientation == 0 or window.orientation == 180
      this.changeOrientation()

  # Development debug only
  silent: (e)->
    @silentClick = true
    return false

  active: ->
    @silentClick = false
    $(@el).addClass('current')

  viewContent: (e)->
    # unless @silentClick
    link = $(e.currentTarget).attr('href')
    App.router.navigate(link, { trigger: true })

    e.preventDefault()
    false

  addItem: (item)->
    @items.push(item)

  isFull: ->
    @items.length >= @limit

  render: ->
    nodes = @page.find(".item")
    protocal = window.location.protocol + "//"

    @items.forEach (item, index)=>
      node = $(nodes[index])
      item.image_url = protocal + item.image_url if !!item.image_url && !item.image_url.match('http')

      node[0].innerHTML = @itemTemplate(item)
      # node.innerHTML = @itemTemplate(item)
      
      # # Assign content type
      node.addClass(item.type.toLowerCase())


      node.addClass('no-image').removeClass('split') unless item.image_url
      
      # strip html tags from article description
      description = item.description
      
      if !!description && description.match(/<\w+>/)
        content = node.find('.info p')[0].innerText
        tmp = document.createElement("div")
        tmp.innerHTML = content
        description = tmp.textContent || tmp.innerText

        node.find('.info p').html(description)
      
      if !description
        node.addClass("no-description")

    this.setElement(@page)

    # @page.css('visibility', 'visible')
    
    
    this.$(".item.article p").each (p)-> $clamp(this, {clamp: 3})
    this.$(".item.split p").each (p)-> $clamp(this, {clamp: 5})

    @page

  changeOrientation: ->
    @page ||= $('.rotatable')

    if @page.find('.v-half') && !@page.find('.v-half').hasClass('row')
      this.doFlipClass(
        @page,
        ['.v-half.nosplit', '.v-half', '.v-third-2', '.v-third.split', '.v-third'],
        ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third'],
        ['half split', 'half', 'third-2', 'third nosplit', 'third']
      )
    else
      this.doFlipClass(
        @page,
        ['.half.split', '.half', '.third-2', '.third.nosplit', '.third'],
        ['half split', 'half', 'third-2', 'third nosplit', 'third'],
        ['v-half nosplit', 'v-half', 'v-third-2', 'v-third split', 'v-third']
      )

    if @page.find('.row.v-half').length > 0
      this.doFlipClass(@page, ['.row.v-half'], ['row v-half'], ['col half'])
    else
      this.doFlipClass(@page, ['.col.half'], ['col half'], ['row v-half'])

    @page

  doFlipClass: (page, classNames, oldNames, newNames)->
    classNames.forEach (className, index)->
      page.find(className).forEach (element)->
        $(element).removeClass(oldNames[index]).addClass(newNames[index])

  destroy: ->
    this.undelegateEvents()

    $(this.el).unbind()

    #Remove view from DOM
    this.remove()
    $(this.el).empty()

    $(this.el).remove()
