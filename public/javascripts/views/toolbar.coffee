class App.Toolbar extends Backbone.View
  el: "header.toolbar"

  events:
    'touchend a.back': 'back'
    'touchend a.menu': 'menu'
    'touchend a.type': 'filter'
    'touchend h1': 'collection'

  initialize: ->
    @backBtn = @actionsBtn = false
    @typeBtn = true
    @popover_template = $('#popover_tpl').html()

  render: ->
    $('.drop-down').hide()
    title = this.$('h1').html(@title)
    backButton = this.$el.find('a.back')
    typeButton = this.$el.find('a.type')
    actionsButton = this.$el.find('div.actions')

    # back button on content view page
    if @backBtn
      if backButton.length == 0
        btn = this.make('a', { href: '#', class: 'back'}, 'Back')
        title.before(btn)
      else
        backButton.show()
    else
      backButton.hide()

    if @typeBtn
      if typeButton.length == 0
        btn = this.make('a', {href: '#', class: 'type'})
        title.before(btn)
      else
        typeButton.show()
    else
      typeButton.hide()

    # actions button on content view page - love, collect and share
    if @actionsBtn
      if actionsButton.length == 0
        this.$el.append(
          $('<div class="actions">
            <a class="heart"></a>
            <a class="collect"></a>
            <a class="share"></a>
          </div>')
        )
      else
        actionsButton.show()
    else
      actionsButton.hide()

  back: ->
    @actionsBtn = @backBtn = false
    @typeBtn = true
    $('#content .pages').removeAttr('style').html('')
    window.history.back()

    false

  menu: ->
    $(document.body).toggleClass('expand-menu')

    false

  filter: ->
    filterPopover = $('#filter-dropdown')

    if filterPopover.length == 0

      data = {
        "class": "filter"
        "collection": [
          { "link": "#1", "query": "shop" }
          { "link": "#2", "query": "read" }
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
        "class": "collection"
        "collection": [
          { "link": "#1", "query": "collection 1" }
          { "link": "#2", "query": "collection 2" }
          { "link": "#3", "query": "collection 3" }
        ]
      }

      html = $(Mustache.to_html(@popover_template, data))
      html.appendTo(this.$el)

    else
      collectionPopover.toggle()

    false
