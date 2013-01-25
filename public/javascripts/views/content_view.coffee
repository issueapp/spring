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
class App.ContentView extends Backbone.View
  el: "#content .pages"

  product_template: Mustache.compile($('#product_tpl').html())
  content_template: Mustache.compile($('#content_tpl').html())

  initialize: ->
    @toolbar = App.toolbar || new App.Toolbar

    @view ||= new App.SwipeView
    @view.on('fetch:next',   => this.fetchNext())
    @view.on('buffer:next',  => this.bufferNext())
    @view.on('buffer:prev',  => this.bufferPrev())
    @view.on('slideTo:prev', => this.slideToPrev())
    @view.on('slideTo:next', => this.slideToNext())
    @view.on('destroy',         this.destroy)

  resetAttrs: ->
    @view.updatePos(0)
    @streamLength = App.stream.size()
    @currentIndex = 0
    @loading = false
    @nextModel = null
    @prevModel = null
    @view.offset = 0

  render: (model)->
    @model = model if model

    @model.attributes.published_at = prettyDate(@model.get('published_at'))

    # render content page node
    if @model.get('type') == 'Article'
      source = $(@content_template(@model.toJSON()))
    else
      source = $(@product_template(@model.toJSON()))

    this.setElement(source)

    # Render single model, return node
    App.toolbar.typeBtn = false

    if model
      source[0]
    else
      if @model.collection
        title = @model.collection.title
      else if @model.get('site')
        title = @model.get('site').title
      else if @model.get('source')
        title = @model.get('source').title

      @toolbar.render(title: title, backBtn: true, typeBtn: false, actionsBtn: true)

      # Content view should fade in
      $(@el).css('opacity', "0").addClass('current')
      $('#content .pages').append( @el )

      $(@el).animate({ opacity: 1 }, 150)
      $('#content .pages').append('<article class="page loading">Loading...</article>')
      this

  fetchNext: ->
    loading = $('#content .pages .loading')
    if target = this.next()
      @prevModel = @model
      @model = target
      @currentIndex += 1
      if @model.get('type') == "Product"
        target_css = 'current product'
      else
        target_css = 'current content'

      ## TODO: this needs to be cleanup, fetch should only fetch a page
      loading.html($(this.render(target)).children()).addClass(target_css).removeClass('loading').attr('data-handle', target.get('handle'))

  next: ->
    current = App.stream.find (item)=>
      handle = $('#content .pages .current').attr('data-handle') || @model.get('handle')
      item.get('handle') == handle

    if !(content = App.stream.findNext(current))
      App.stream.fetchNext()

    else
      content

  prev: ->
    current = App.stream.find (item)=>
      item.get('handle') == $('#content .pages .current').attr('data-handle')

    content = App.stream.findPrev(current)

  bufferNext: ->
    target = this.next()
    if target instanceof Backbone.Model
      if @nextModel
        @prevModel = @model
        @model = @nextModel
      @nextModel = target

      $('#content .pages').append($(this.render(target)))

      if @streamLength != App.stream.size()
        @streamLength = App.stream.size()
        @loading = false

      @currentIndex += 1
      if @currentIndex > @streamLength/2 && !@loading
        App.stream.fetchNext()
        @loading = true

  bufferPrev: ->
    if target = this.prev()
      @nextModel = @model
      @model = @prevModel
      @prevModel = target

      @currentIndex -= 1
      $('#content .pages .padding').after(this.render(target))

  slideToNext: ->
    if @currentIndex < 2
      @currentIndex = 2
      this.render(@model)

  slideToPrev: ->
    if @currentIndex == 2
      @currentIndex -= 1
    else if @currentIndex == 1
      @currentIndex -= 1
      this.render(@prevModel)

  show: ->
    this.$el.css('opacity', 1)

  clear: ->
    this.$el.html('').removeAttr('style')

  destroy: (garbage)->
    item = $(garbage)
    item.find('.image').each ->
      $(this).removeAttr("style")

    item.off()
    item.remove()

