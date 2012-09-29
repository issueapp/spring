class App.Toolbar extends Backbone.View
  el: "header.toolbar"
  
  events:
    'ontouchstart a.signup': 'signup'
    'ontouchstart a.back-home': 'backHome'
    'click a.back': 'back'
    
  render: ->
    titleTag = this.$('h1').html(@title)
      
    btn = this.$('a.button.back')  
    
    if @backBtn
      if btn.length == 0
        btn = this.make('a', { href: "#", class: "button back"}, "Back")
        titleTag.before(btn)
    else
      btn.remove()
      
    signupBtn = this.$('a.button.signup')
    
    if @signupButton
      if signupBtn.length == 0
        signupBtn = this.make('a', { href: "#", class: "button blue signup", onclick: "return false;"}, "SignUp")
        
        titleTag.after(signupBtn)
    else
      signupBtn.remove()
  
  
  signup: ->
    $('#pages').hide()
    $('#signup').show()
    
    btn = this.$('a.button.back-home')
    
    if btn.length == 0
      backBtn = this.make('a', { href: "#", class: "button back-home", onclick: "return false;"}, "Back")
      this.$('h1').html("SIGN UP").before(backBtn)
    
    false
    
  backHome: ->
    $('#signup').hide()
    $('#pages').show()
    this.$('a.button.back-home').remove()
  
  back: =>
    $('#content .pages').removeAttr("style").html('')
    $(@el).find('a.back').remove()
    $(@el).find('a.actions').remove()
    
    window.history.back()
    
    false