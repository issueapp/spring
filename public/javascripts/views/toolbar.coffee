class App.Toolbar extends Backbone.View
  el: "header.toolbar"

  events:
    'touchstart a.back': 'back'
    'touchend a.menu': 'menu'
    'touchend a.type': 'filter'
    'touchend .title': 'collection'
    'touchend #filter-dropdown a': 'toggleFilterStatus'
    'touchend #collection-dropdown li': 'toggleCollectionStatus'

  initialize: ->
    @channelBtn = @backBtn = @actionsBtn = false
    @typeBtn = true
    @popover_template = $('#popover_tpl').html()

    @titleTag = this.$('.title')
    @followButton = this.$('a.follow')

    @backButton = this.$('a.back')
    @channelButton = this.$('a.channel')
    @typeButton = this.$('a.type')
    @actionsButton = this.$('div.actions')

  render: (options)->
    options = _.extend({
      backBtn: false,
      typeBtn: false,
      actionsBtn: false,
      title: true,
      followBtn: false,
      channelBtn: false
    }, options)

    $('.drop-down').hide()

    # Build step
    if typeof(options.title) == "string"
      @title = options.title
      @titleTag.html('<span>'+@title+'</span>')

    # back button on content view page
    if @backButton.length == 0
      @backButton = $(this.make('a', { href: '#', class: 'back'}, 'Back'))
      @titleTag.before(@backButton)

    @backButton.toggle(options.backBtn)

    # channel button on stream view page, can be anything which users can follow
    if @channelButton.length == 0
      @channelButton = $(this.make('a', { href: '#stream', class: 'channel'}, 'Taylor'))
      @titleTag.before(@channelButton)

    @channelButton.toggle(options.channelBtn)

    # follow button on stream view page
    if @followButton.length == 0
      @followButton = $(this.make('a', { href: '#stream', class: 'follow'}, 'follow'))
      @titleTag.before(@followButton)

    @followButton.toggle(options.followBtn)

    # type selector
    if @typeButton.length == 0
      @typeButton = $(this.make('a', {href: '#', class: 'type'}))
      @titleTag.before(@typeButton)

    @typeButton.toggle(options.typeBtn)

    # actions button on content view page - love, collect and share
    if @actionsButton.length == 0
      @actionsButton = $('<div class="actions">
        <a class="heart"></a>
        <a class="collect"></a>
        <a class="share"></a>
      </div>')
      this.$el.append(@actionsButton)

    @actionsButton.toggle(options.actionsBtn)

  back: ->
    @actionsBtn = @backBtn = false
    @typeBtn = false
    $('#content .pages').removeAttr('style').html('')
    window.history.back()

    false

  menu: ->
    App.menu.toggle()

  filter: ->
    filterPopover = $('#filter-dropdown')

    if filterPopover.length == 0

      data = {
        'type': 'filter'
        'collection': [
          { 'class': 'view-all active', 'link': '?type=all', 'content': 'view all' }
          { 'class': 'shop', 'link': '?type=product', 'content': 'shop' }
          { 'class': 'read', 'link': '?type=article', 'content': 'read' }
          { 'class': 'photo', 'link': '?type=picture', 'content': 'photo' }
        ]
      }

      html = $(Mustache.to_html(@popover_template, data))
      html.appendTo(this.$el)

    else
      filterPopover.toggle()

    false

  collection: ->
    collectionPopover = $('#collection-dropdown')

    if collectionPopover.length == 0

      data = {
        'type': 'collection'
        'collection': [
          { 'link': '#1', 'content': 'Latest Arrivals' }
          { 'link': '#2', 'content': 'Editors choice' }
          { 'link': '#3', 'content': 'Promotions' }
        ]
      }

      html = $(Mustache.to_html(@popover_template, data))

      # DEMO Only
      html.find('li').eq(0).addClass('active')

      html.appendTo(this.$el)

    else
      collectionPopover.toggle()

    false

  toggleFilterStatus: (e)->
    target = $(e.target)
    this.$el.find('#filter-dropdown .active').removeClass('active')
    $(e.currentTarget).addClass('active')
    App.router.navigate(target.attr('href'), { trigger: true })

    e.preventDefault()

  toggleCollectionStatus: (e)->
    this.$el.find('#collection-dropdown .active').removeClass('active')
    $(e.currentTarget).addClass('active')

    false
    App.menu.toggle()
