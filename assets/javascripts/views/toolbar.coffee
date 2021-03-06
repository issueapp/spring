class App.Toolbar extends Backbone.View
  el: ".toolbar"

  events:
    "click a.back": 'back'
    "click a.menu": 'menu'

  initialize: ->
    @backBtn = @actionsBtn = false
    @typeBtn = true
    @popover_template = $('#popover_tpl').html()

    @titleTag = this.$('.title')
    @followButton = this.$('a.follow')

    @backButton = this.$('a.back')
    @typeButton = this.$('a.type')
    @actionsButton = this.$('div.actions')
    
  render: (options)->
    options = _.extend({
      backBtn: false,
      typeBtn: false,
      actionsBtn: false,
      title: true,
      followBtn: false
    }, options)

    $(@el).show()
    $('.drop-down').hide()

    # Build step
    if typeof(options.title) == "string"
      @title = options.title
      @titleTag.html('<span>'+@title+'</span>')

    # back button on content view page
    # if @backButton.length == 0
    #   @backButton = $(this.make('a', { href: '#', class: 'back'}, 'Back'))
    #   @titleTag.before(@backButton)

    @backButton.toggle(options.backBtn)

    if window.location.host.match(/localhost/)
      @reloadButton = this.$('a.reload')
      # 
      # if @reloadButton.length == 0
      #   @reloadButton = $(this.make('a', { href: '', class: 'icon reload follow', onclick:"window.location.reload(true); return false"}, 'reload'))
      #   @titleTag.before(@reloadButton)
    else
      @reloadButton.hide()

    # channel button on stream view page, can be anything which users can follow
    if @followButton.length == 0
      @followButton = $(this.make('a', { href: '#stream', class: 'follow'}, 'follow'))
      @titleTag.before(@followButton)

    @followButton.toggle(options.followBtn)

    # type selector
    # if @typeButton.length == 0
    #   @typeButton = $(this.make('a', {href: '#', class: 'type'}))
    #   @titleTag.before(@typeButton)

    @typeButton.toggle(options.typeBtn)

    # actions button on content view page - love, collect and share
    # if @actionsButton.length == 0
    #   @actionsButton = $('<div class="actions">
    #     <a class="heart"> </a>
    #     <a class="collect"> </a>
    #     <a class="share"> </a>
    #   </div>')
    #   this.$el.append(@actionsButton)

    @actionsButton.toggle(options.actionsBtn)

  show: ->
    $(@el).show()
    
  hide: ->
    $(@el).hide()

  back: (e)->
    @typeBtn = @actionsBtn = @backBtn = false

    window.history.back()

    e.preventDefault()
    e.stopPropagation()

  menu: ->
    App.menu.toggle()

