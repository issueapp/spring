class App.Toolbar extends Backbone.View
  el: "header.toolbar"

  events:
    'touchstart a.back': 'back'
    'touchstart a.menu': 'menu'

  initialize: ->
    @backBtn = @actionsBtn = false
    @typeBtn = true

  render: ->
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
