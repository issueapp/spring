class App.Toolbar extends Backbone.View
  el: "header.toolbar"

  events:
    'touchstart a.back': 'back'

  render: ->
    title = this.$('h1').html(@title)
    backButton = this.$el.find('a.back')
    actionsButton = this.$el.find('div.actions')

    # back button on content view page
    if @backBtn
      if backButton.length == 0
        btn = this.make('a', { href: '#', class: 'button back'}, 'Back')
        title.before(btn)
      else
        backButton.show()
    else
      backButton.hide()

    # actions button on content view page - love, collect and share
    if @actionsBtn
      if actionsButton.length == 0
        this.$el.append(
          $('<div class="actions">
            <i class="icon-heart"></i>
            <i class="icon-plus"></i>
            <i class="icon-share-alt"></i>
          </div>')
        )
      else
        actionsButton.show()
    else
      actionsButton.hide()

  back: ->
    @actionsBtn = @backBtn = false
    $('#content .pages').removeAttr('style').html('')
    window.history.back()

    false
