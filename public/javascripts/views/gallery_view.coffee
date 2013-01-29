class App.GalleryView extends App.SwipeView
  el: '#gallery'

  # events:
    # 'click img': 'toggleText'

  # <header class="toolbar">
  #   <a class="back">back</a>
  #   <span>20 of 20</span>
  #   <a class="share">share</a>
  # </header>
  # <footer>
  #   <h3>name of the photo</h3>
  #   <p class="description">Lorem ipsum dolor sit amet, consectetur adipisicing elit</a>
  #   <nav class="paginate"></nav>
  # </footer>
  template: Mustache.compile(
    '
    <div class="swipe-paging">
      {{#collection}}
      <div class="page image">
        <img src="{{source}}">
      </div>
      {{/collection}}
    </div>
    '
  )

  initialize: (data)->
    @offset ||= 0
    @currentIndex ||= 0
    @startClientX = @currentClientX = 0

    # Set current page
    @currentPage = this.$('.current').eq(0)

    if @currentPage.length == 0
      @currentPage = $(@el).children(":not(.padding)").first().addClass('current')

    if expendMenu = $('body.expand-menu')[0]
      @viewport ||= expendMenu.offsetWidth
    else
      @viewport ||= @el.parentNode.offsetWidth

    @images = { 'collection': [] }
    @gallery = $('#gallery')

    $(data.target).find('a').forEach (item)=>
      @images.collection.push { 'source': $(item).attr('href') }

    @bufferSize ||= @images.collection.length

  open: ->
    @gallery.html @template(@images)
    this.setElement('#gallery .swipe-paging')
    this.$el.css('height', window.innerHeight)
    this.$el.find('.page:nth-child(1)').addClass('current')
