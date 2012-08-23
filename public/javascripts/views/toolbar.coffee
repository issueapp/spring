class App.Toolbar extends Backbone.View
  el: "nav.toolbar"
  
  render: ->
    titleTag = this.$('h1').html(@title)
      
    btn = this.$('a.button.back')  
    
    if @backBtn
      if btn.length == 0
        btn = this.make('a', { href: "#", class: "button back", onclick: "window.history.back(); return false;"}, "Back")
        titleTag.before(btn)
    else
      btn.remove()
      